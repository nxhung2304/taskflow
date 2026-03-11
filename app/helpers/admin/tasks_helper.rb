module Admin::TasksHelper
  def status_badge_class(status)
    case status.to_s
    when "todo"
      "bg-secondary"
    when "in_progress"
      "bg-warning text-dark"
    when "completed"
      "bg-success"
    else
      "bg-secondary"
    end
  end

  def list_specific?
    @list.present?
  end
end
