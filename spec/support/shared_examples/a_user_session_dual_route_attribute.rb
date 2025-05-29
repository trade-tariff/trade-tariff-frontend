RSpec.shared_examples_for 'a user session dual route attribute' do |attribute, value|
  %i[uk xi].each do |service|
    describe "##{attribute}_#{service}=" do
      subject(:user_session) { build(:user_session) }

      let(:initial_value) { { '105' => ['C644', 'Y929', ''] } }
      let(:expected_value) { value.merge(initial_value) }

      before { user_session.public_send("#{attribute}_#{service}=", initial_value) }

      it 'updates the existing session hash with new values' do
        expect { user_session.public_send("#{attribute}_#{service}=", value) }
          .to change(user_session, "#{attribute}_#{service}")
          .from(initial_value)
          .to(expected_value)
      end
    end

    describe "#{attribute}_#{service}" do
      context 'when the session already specifies a value' do
        subject(:user_session) { build(:user_session, attribute => { service.to_s => value }) }

        it { expect(user_session.public_send("#{attribute}_#{service}")).to eq(value) }
      end

      context 'when the session specifies no value' do
        subject(:user_session) { build(:user_session) }

        it { expect(user_session.public_send("#{attribute}_#{service}")).to eq({}) }
      end
    end
  end
end
