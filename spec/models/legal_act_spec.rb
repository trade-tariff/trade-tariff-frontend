require 'spec_helper'

describe LegalAct do
  subject(:legal_act) { build(:legal_act) }

  shared_examples 'a parsed date field' do |field|
    describe "##{field}=" do
      context 'when the new date is a valid date string' do
        let(:new_date) { '2021-01-01' }

        it 'returns a parsed date' do
          expect { legal_act.public_send("#{field}=", new_date) }
            .to change(legal_act, field)
            .from(nil)
            .to(Date.parse(new_date))
        end
      end

      context 'when the new date is nil' do
        let(:new_date) { nil }

        it 'returns nil' do
          expect { legal_act.public_send("#{field}=", new_date) }
            .not_to change(legal_act, field)
            .from(nil)
        end
      end
    end
  end

  it_behaves_like 'a parsed date field', :validity_start_date
  it_behaves_like 'a parsed date field', :validity_end_date
end
