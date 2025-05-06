class FetchDataJob < ApplicationJob
  queue_as :default

  def perform(user_id, directory)
    media_ext = ['.mp4', '.mp3', '.mov', '.jpg', '.png', '.jpeg', '.avi', '.mkv', '.webm', '.gif']
    web_ext   = ['.html', '.css', '.js', '.php']
    doc_ext   = ['.pdf', '.doc', '.docx', '.xls', '.xlsx', '.ppt', '.pptx', '.txt', '.md']
    code_ext  = ['.rb', '.py', '.java', '.c', '.cpp', '.go', '.ts', '.json', '.xml', '.sh', '.sql', '.yml']

    user = EphemeralUser.find(user_id)
    ssh = SftpService.new(user).ssh_session

    files = collect_metadata(ssh, directory)

    files.each do |file|
      if is_media(file[:file_name],media_ext)
        next
      end

      if file[:content_hash].blank?
        next
      end

      file_type     = find_file_type(file[:file_name],web_ext,doc_ext,code_ext)
      is_anomalous  = is_anomalous(file[:file_name])
      is_archivable = file[:accessed_at] < 1.month.ago
      is_duplicate = false

      group = Group.find_by(content_hash: file[:content_hash])
      group_id = nil;
      if group.present?
        is_duplicate = true
        group_id = group.id
      end

      file_record = FileRecord.create!(
        ephemeral_user_id: user.id,
        file_name: file[:file_name],
        file_size: file[:file_size],
        path: file[:path],
        is_duplicate: is_duplicate,
        is_anomalous: is_anomalous,
        is_archivable: is_archivable,
        group_id: group_id,
        file_type: file_type,
        created_at: file[:created_at],
        accessed_at: file[:accessed_at],
        modified_at: file[:modified_at]
      )

      if group
        original_file = FileRecord.find_by(id: group.original_file_id)
        if file[:created_at] < original_file.created_at
          group.update!(original_file_id: file_record.id)
          original_file.update!(is_duplicate: true)
          file_record.update!(is_duplicate: false,group_id: group.id)
        else
          file_record.update!(is_duplicate: true, group_id: group.id)
        end
      
        group.total_files += 1
        group.saved_size += file[:file_size]
        group.save!
      else
        group = Group.create!(
          content_hash:     file[:content_hash],
          saved_size:       0,
          total_files:      1,
          original_file_id: file_record.id,
          group_type:       file_type
        )
        file_record.update!(group_id: group.id, is_duplicate: false)
      end

      if file[:created_at]  > 7.days.ago
        create_tag(file_record, 'recently_created')
      end

      if file[:modified_at] > 7.days.ago
        create_tag(file_record, 'recently_modified') 
      end
    end
  end

  private

  def collect_metadata(ssh, directory)
    command = <<~BASH
      find "#{directory}" -type f -print0 | while IFS= read -r -d '' file; do
        size=$(stat -c %s "$file")
        access=$(stat -c %X "$file")
        modify=$(stat -c %Y "$file")
        create=$(stat -c %W "$file")
        md5=$(md5sum "$file" 2>/dev/null | awk '{print $1}')
        echo "$file|$size|$create|$access|$modify|$md5"
      done
    BASH

    output = ssh.exec!(command)
    if output.nil? || output.empty?
      return []
    end

    files = []

    output.lines.each do |line|
      path, size, created, accessed, modified, hash = line.strip.split('|')
      created_time = Time.at(modified.to_i) 
      if created.to_i > 0 
        created_time = Time.at(created.to_i)
      end

      files << {
        file_name:    File.basename(path),
        path:         path,
        file_size:    size.to_i,
        created_at:   created_time,
        accessed_at:  Time.at(accessed.to_i),
        modified_at:  Time.at(modified.to_i),
        content_hash: hash
      }
    end
    files
  end
  
  def is_media(file_name, media_extensions)
    ext = File.extname(file_name).downcase
    media_extensions.include?(ext)
  end
  
  def is_anomalous(file_name)
    ext = File.extname(file_name)
    if ext.empty? || file_name.include?('@') || file_name.include?('!') || file_name.include?('$')
      return true
    end
    false
  end
  
  def find_file_type(file_name, web, doc, code)
    ext = File.extname(file_name).downcase
  
    if web.include?(ext)
      return 'web'
    elsif doc.include?(ext)
      return 'doc'
    elsif code.include?(ext)
      return 'code'
    else
      return 'not_defined'
    end
  end

  def create_tag(file_record, tag_name)
    file_record.tags.create!(tag_name: tag_name)
  end
end
