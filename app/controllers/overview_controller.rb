class OverviewController < ApplicationController
  before_action :authenticate_user!

  def index
    files = current_user.file_records.includes(:tags)
    files = apply_filters(files)
    @files= files.page(get_page).per(10)
  end
  
  def anomalous
    files = current_user.file_records.where(is_anomalous: true).includes(:tags)
    files = apply_filters(files)
    @files= files.page(get_page).per(10)
  end

  def duplicates
    files = current_user.file_records.where(is_duplicate: true).includes(:tags)
    files = apply_filters(files)
    @files= files.page(get_page).per(10)
  end

  def archivable
    files = current_user.file_records.where(is_archivable: true).includes(:tags)
    files = apply_filters(files)
    @files= files.page(get_page).per(10)
  end

  private

  def apply_filters(files)
    query = nil
    if permitted_params[:search].present?
      query = permitted_params[:search].to_s.strip
    end

    folder = nil
    if permitted_params[:folder].present?
      folder = permitted_params[:folder].to_s.strip
    end

    tags = nil
    if permitted_params[:tags].present?
      tags = permitted_params[:tags]
    end

    sort_by = "created_at"
    if permitted_params[:sort_by].present?
      sort_by = params[:sort_by]
    end

    if !query.nil?
      files = files.where("file_name ILIKE ?", "%#{query}%")
    end

    if !folder.nil?
      files = files.where("path ILIKE ?", "%#{folder}%")
    end

    if !tags.nil?
      files = files.joins(:tags).where(tags: { tag_name: tags })
    end

    files.order(sort_by => :desc)
  end
  
  def get_page
    page = 1
    if permitted_params[:page].present?
      page = permitted_params[:page]
    end
    page
  end

  def permitted_params
    params.permit(:search, :folder, :tags, :sort_by, :page, :commit)
  end

end