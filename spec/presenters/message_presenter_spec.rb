require 'spec_helper'

describe MessagePresenter do

  let(:message) { double('message',
                       id: 22,
                       content: 'Hey Ya!',
                       created_at: 2.hours.ago,
                       sender_handle: 'bob@CUSS',
                       attachment: nil,
                       formatted_readers: 'jeff@AML read this.')
  }
  let(:user) { double('user') }

  before do
    message.stub(:generate_view_class).with(user).and_return('message msg-22 recieved read')
    message.stub(:sent_to?).with(user).and_return(false)
  end

  subject { MessagePresenter.new(message, user) }

  describe '#as_json' do

    let(:expected) {{ 
        id: 22,
        content: 'Hey Ya!',
        created_at: 2.hours.ago.strftime("%a %b %e %Y %T"),
        sender: 'bob@CUSS',
        view_class: 'message msg-22 recieved read',
        readers: 'jeff@AML read this.' 
    }}

    it 'returns the message as json in the context of the user' do
      subject.as_json.should == expected.as_json
    end

    context 'when the message was sent to the user' do

      before { message.stub(:sent_to?).with(user).and_return(true) }

      it 'does not include the :readers key in the json' do
        subject.as_json.should == expected.reject { |key, value| key == :readers }.as_json
      end

      context 'when the :transcript option is given' do

        it 'does include the :readers key in the json' do
          subject.as_json(transcript: true).should == expected.as_json
        end
      end
    end
  end
end

