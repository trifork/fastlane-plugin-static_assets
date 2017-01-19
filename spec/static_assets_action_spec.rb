describe Fastlane::Actions::StaticAssetsAction do
  describe '#run' do
    it 'prints a message' do
      expect(Fastlane::UI).to receive(:message).with("The static_assets plugin is working!")

      Fastlane::Actions::StaticAssetsAction.run(nil)
    end
  end
end
