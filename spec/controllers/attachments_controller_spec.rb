require 'spec_helper'

describe AttachmentsController do
   
  let(:base_name) { "test_file.txt" }
  let(:upload_file) { fixture_file_upload("/files/" + base_name, "text/plain") }
  let(:payload) {{ "payload" => upload_file }}

  describe "POST 'create'" do

    let(:params) {{ attachment: payload, format: :js }}

    context "for unauthenticated users" do

      before { controller.stub!(:current_user).and_return(nil) }

      it "redirects to the sign_in path'" do
        post :create, params
        expect(response).to redirect_to(signin_path)
      end
    end

    context "for authenticated users" do
    
      let(:current_user) { stub('current_user') }
      before(:each) { controller.stub!(:current_user).and_return(current_user) }
 
      context "with invalid parameters" do

        let(:message) { stub('message', attachment: nil).as_null_object }

        it "does not push a message" do
          current_user.stub(:create_attached_message).and_return(message)
          Pusher.should_not_receive(:push_message)
          post :create, params
        end
      end

      context "with valid parameters" do

        let(:attachment) { stub('attachment') }
        let(:message) { stub('message', attachment: attachment).as_null_object }

        it "creates a message with attachment belonging to the current user" do
          current_user.should_receive(:create_attached_message).with(payload).and_return(message)
          post :create, params
        end

        it "generates the message outgoing receipt" do
          current_user.stub(:create_attached_message).and_return(message)
          message.should_receive(:generate_outgoing_receipt)
          post :create, params
        end

        it "generates the message incoming receipts" do
          current_user.stub(:create_attached_message).and_return(message)
          message.should_receive(:generate_incoming_receipts).with(attachment: attachment)
          post :create, params
        end

        it "pushes the message" do
          current_user.stub(:create_attached_message).and_return(message)
          Pusher.should_receive(:push_message).with(message)
          post :create, params
        end
      end
    end
  end
end
