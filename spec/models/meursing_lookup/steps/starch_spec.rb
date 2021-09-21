require 'spec_helper'

RSpec.describe MeursingLookup::Steps::Starch do
  it_behaves_like 'an answer step', 'starch' do
    describe '#current_meursing_code_level' do
      it { expect(step.current_meursing_code_level).to eq(step.meursing_codes) }
    end
  end
end
