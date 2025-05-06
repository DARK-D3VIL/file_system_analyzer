class DashboardController < ApplicationController
  before_action :authenticate_user!
  def index
    @total_files        = current_user.file_records.count
    @total_size_mb      = (current_user.file_records.sum(:file_size) / 1048576.to_f).round(2)
    @duplicates_count   = current_user.file_records.where(is_duplicate: true).count
    @archivable_count   = current_user.file_records.where(is_archivable: true).count
    @anomalous_count    = current_user.file_records.where(is_anomalous: true).count
  
    @file_type_distribution = current_user.file_records.group(:file_type).count

    @chart_data = duplicate_group_data
  end

  def duplicate_group_data
    groups_with_files = Group.joins(:file_records).where(file_records: { ephemeral_user_id: current_user.id })

    grouped_files = groups_with_files.group("groups.id").select("groups.id, COUNT(file_records.id) AS file_count, groups.saved_size")

    filtered_groups = []
    grouped_files.each do |group|
      if group.file_count > 1
        filtered_groups << group
      end
    end

    duplicate_group_chart = [] 
    filtered_groups.each do |group|
      duplicate_group_chart << [group.file_count, group.saved_size]
    end

    chart_data = [] 
    duplicate_group_chart.each do |total_files, saved_size|
      chart_data << [total_files, saved_size]
    end
    chart_data
  end
end
  