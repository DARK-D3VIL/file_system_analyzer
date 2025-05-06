class DataCleanJob < ApplicationJob
  queue_as :default

  def perform(user_id)
    user = EphemeralUser.find_by(id: user_id)
    if !user
      return
    end
    group_ids = []
    user.file_records.each do |file|
      if file.group_id.present?
        group_ids << file.group_id 
      end
    end
    group_ids.uniq!
    user.destroy
    group_ids.each do |group_id|
      group = Group.find_by(id: group_id)
      if group
        group.destroy 
      end
    end
  end
end
