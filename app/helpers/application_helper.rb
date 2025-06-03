module ApplicationHelper
  def file_status_tooltip(record)
    return "Duplicate file" if record&.is_duplicate
    return "Anomalous file" if record&.is_anomalous
    return "Archivable file" if record&.is_archivable
    "Normal file"
  end
end
