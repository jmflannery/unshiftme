require 'spec_helper'

describe MessagesController do

  let(:user) { double('user', user_name: 'jack', to_param: 'jack') }

  describe "POST create" do

    let(:message) { double('message',
      generate_incoming_receipts: true,
      generate_outgoing_receipt: true)
    }
    let(:attr) {{ "content" => "i like turtles" }}
    let(:params) {{ message: attr, user_id: user, format: :js }}

    before(:each) do
      user.stub(messages: double('user messages'))
      user.messages.stub(:new).with(params[:message]).and_return(message)
      Pusher.stub(:push_message).with(message)
    end

    context "with an authenticated user" do
       
      before(:each) { mock_sign_in(user) }

      it "builds and saves a new message" do
        user.messages.should_receive(:new).with(params[:message]).and_return(message)
        message.should_receive(:save)
        post :create, params
      end
      
      context "on save success" do

        before(:each) { message.stub(save: true) }
             
        it "generates the message's incoming receipts" do
          message.should_receive(:generate_incoming_receipts)
          post :create, params
        end

        it "generates the messages outgoing receipt" do
          message.should_receive(:generate_outgoing_receipt)
          post :create, params
        end

        it "broadcasts the message" do
          Pusher.should_receive(:push_message).with(message)
          post :create, params
        end
      end

      context "on save failure" do

        before(:each) { message.stub(save: false) }

        it "does not generate reciepts or push the message" do
          message.should_not_receive(:generate_incoming_receipts)
          message.should_not_receive(:generate_outgoing_receipt)
          Pusher.should_not_receive(:push_message).with(message)
          post :create, params
        end
      end
    end

    context "with an unauthenticated user" do

      it "redirects to the signin path" do
        post :create, params
        expect(response).to redirect_to signin_path
      end
    end
  end

  describe "GET index" do
    
    let(:params) {{ user_id: user, format: :json }}

    context "with an authenticated user" do

      let(:messages) { double('messages') }
      before { mock_sign_in(user) }

      it "gets the current_users messages" do
        user.should_receive(:display_messages).with(no_args).and_return(messages)
        get :index, params
      end
      
      it "returns the messages as json" do
        user.stub(:display_messages).with(no_args).and_return(messages)
        controller.should_receive(:render).with(json: messages)
        controller.should_receive(:render)
        get :index, params
      end
    end

    context "with an unauthenticated user" do

      it "redirects to the signin path" do
        get :index, params
        expect(response).to redirect_to signin_path
      end
    end
  end

  describe "PUT update" do

    let(:message) { double('message', id: '22') }
    let(:params) {{ id: message.id, user_id: user, format: :js, remote: true }}


    context "for authenticated users" do

      before(:each) { mock_sign_in(user) }

      context "when message exists" do

        before(:each) do
          Message.stub(:find_by_id).with(message.id).and_return(message)
          message.stub(:mark_read_by).with(user)
          Pusher.stub(:push_readers).with(message)
        end

        it "marks the message acknowledged by the current user" do
          message.should_receive(:mark_read_by).with(user)
          put :update, params
        end

        it "pushes the acknowledgment to the message owner" do
          Pusher.should_receive(:push_readers).with(message)
          put :update, params
        end
      end

      context "when message does not exist" do

        before(:each) do
          Message.stub(:find_by_id).with(message.id).and_return(nil)
        end

        it "does not mark the message acknowledged and push the acknowledgement" do
          message.should_not_receive(:mark_read_by).with(user)
          Pusher.should_not_receive(:push_readers).with(message)
          put :update, params
        end
      end
    end

    context "for unauthenticated users" do

      it "redirects to the signin path" do
        put :update, params
        expect(response).to redirect_to signin_path
      end
    end
  end
end

