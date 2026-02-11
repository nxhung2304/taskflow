module Moveable
  extend ActiveSupport::Concern

  included do
    before_action :set_moveable_record, only: [ :move ]
    before_action :set_resource_blueprint, only: [ :move ]
  end

  def move
    position_form = PositionForm.new(position: move_params[:position])
    if position_form.valid?
      @moveable_record.insert_at(position_form.position.to_i)
      @moveable_record.reload
      render json: @resource_blueprint.render(@moveable_record)
    else
      render json: { errors: position_form.errors.full_messages }, status: :unprocessable_entity
    end
  end

  private

  def set_moveable_record
    @moveable_record = controller_name.classify.constantize.find(params[:id])
  end

  def set_resource_blueprint
    blueprint_class_name = "#{controller_name.classify}Blueprint"
    @resource_blueprint = blueprint_class_name.constantize
  end
end
