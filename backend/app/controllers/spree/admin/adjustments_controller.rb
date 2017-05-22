module Spree
  module Admin
    class AdjustmentsController < ResourceController
      belongs_to 'spree/order', find_by: :number

      create.after :update_totals
      destroy.after :update_totals
      update.after :update_totals

      skip_before_action :load_resource, only: [:toggle_state, :edit, :update, :destroy]

      before_action :find_adjustment, only: [:destroy, :edit, :update]

      helper_method :reasons_for, :adjustable_candidates

      def index
        @adjustments = @order.all_adjustments.order("created_at ASC")
      end

      private

      def find_adjustment
        # Need to assign to @object here to keep ResourceController happy
        @adjustment = @object = parent.all_adjustments.find(params[:id])
      end

      def update_totals
        @order.reload.update!
      end

      # Override method used to create a new instance to correctly
      # associate adjustment with order
      def build_resource
        model_class.new(default_params)
      end

      def default_params
        { order: parent, adjustable: parent }
      end

      def reasons_for(_adjustment)
        [
          Spree::AdjustmentReason.active.to_a,
          @adjustment.adjustment_reason
        ].flatten.compact.uniq.sort_by { |r| r.name.downcase }
      end

      def adjustable_candidates
        candidates = [{id: parent.id, description: "Order", type: "Spree::Order"}]

        parent.line_items.each do |li|
          candidates << {id: li.id, description: li.variant.name, type: "Spree::LineItem" }
        end

        return candidates
      end
    end
  end
end
