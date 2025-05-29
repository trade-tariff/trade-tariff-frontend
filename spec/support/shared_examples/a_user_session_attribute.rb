RSpec.shared_examples_for 'a user session attribute' do |attribute, expected_value|
  describe "##{attribute}" do
    context 'when the key is not present on the session' do
      subject(:user_session) { build(:user_session, attribute => nil) }

      it { expect(user_session.public_send(attribute)).to be_nil }
    end

    context 'when the key is present on the session' do
      subject(:user_session) { build(:user_session, attribute.to_s => expected_value) }

      it { expect(user_session.public_send(attribute)).to eq(expected_value) }
    end
  end

  describe "##{attribute}=" do
    subject(:user_session) { build(:user_session, attribute => nil) }

    it 'correctly sets the value on the session' do
      expect { user_session.public_send("#{attribute}=", expected_value) }
        .to change(user_session, attribute)
        .from(nil)
        .to(expected_value)
    end
  end
end
