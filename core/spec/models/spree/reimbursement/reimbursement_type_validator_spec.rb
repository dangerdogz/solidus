require 'spec_helper'

module Spree
  describe Reimbursement::ReimbursementTypeValidator, type: :model do
    class DummyClass
      include Spree::Reimbursement::ReimbursementTypeValidator

      class_attribute :expired_reimbursement_type
      self.expired_reimbursement_type = Spree::ReimbursementType::Credit

      class_attribute :refund_time_constraint
      self.refund_time_constraint = Spree::Config[:refund_time_constraint].days
    end

    let(:return_item) do
      create(
        :return_item,
        preferred_reimbursement_type: preferred_reimbursement_type
      )
    end
    let(:dummy) { DummyClass.new }
    let(:preferred_reimbursement_type) { Spree::ReimbursementType::Credit.new }

    describe '#past_reimbursable_time_period?' do
      subject { dummy.past_reimbursable_time_period?(return_item) }

      before do
        allow(return_item).to receive_message_chain(:inventory_unit, :shipment, :shipped_at).and_return(shipped_at)
      end

      context 'it has not shipped' do
        let(:shipped_at) { nil }

        it 'is not past the reimbursable time period' do
          expect(subject).to be_falsey
        end
      end

      context 'it has shipped and it is more recent than the time constraint' do
        let(:shipped_at) { (dummy.refund_time_constraint - 1.day).ago }

        it 'is not past the reimbursable time period' do
          expect(subject).to be false
        end
      end

      context 'it has shipped and it is further in the past than the time constraint' do
        let(:shipped_at) { (dummy.refund_time_constraint + 1.day).ago }

        it 'is past the reimbursable time period' do
          expect(subject).to be true
        end
      end
    end
  end
end
