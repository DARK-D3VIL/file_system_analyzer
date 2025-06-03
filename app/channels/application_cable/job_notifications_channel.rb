module ApplicationCable
  class JobNotificationsChannel < Channel
    def subscribed
      stream_for "job_notifications_user_#{current_user.id}"
    end
  end
end
