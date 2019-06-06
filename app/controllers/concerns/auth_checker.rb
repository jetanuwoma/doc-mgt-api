

module AuthChecker
  def require_admin
    unless current_user&.admin?
      raise ExceptionHandler::UnauthorizedUser,
            Message.admin_required
    end
  end

  def can_update_user(user, user_update_params)
    role = user_update_params[:role]
    first_name = user_update_params[:first_name]
    last_name = user_update_params[:last_name]

    if role.present?
      if !first_name.present? && !last_name.present? && !is_current_user?(user)
        require_admin
      elsif first_name.present? || last_name.present? && is_current_user?(user)
        raise ExceptionHandler::UnauthorizedUser, Message.access_not_granted
      else
        raise ExceptionHandler::UnauthorizedUser, Message.access_not_granted
      end
    else
      unathorize_current_user_error(user)
    end
  end

  def unathorize_current_user_error(user)
    unless is_current_user?(user)
      raise ExceptionHandler::UnauthorizedUser, Message.access_not_granted
    end
  end

  def is_current_user?(user)
    current_user&.id == user.id
  end
end
