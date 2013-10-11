require 'spec_helper'

describe AttachmentsController do
   
  let(:upload_file) { fixture_file_upload("/files/test_file.txt", "text/plain") }
  let(:payload) {{ "payload" => upload_file }}
  let(:user) { double('user', { user_name: 'jack', to_param: 'jack' }) }

  describe "POST create" do

    let(:params) {{ user_id: user, attachment: payload, format: :js }}

    context "for authenticated and authorized users" do
    
      before(:each) { controller.stub(:current_user).and_return(user) }
 
      context "with valid parameters" do

        let(:attachment) { double('attachment') }
        let(:message) {
          double('message',
            attachment: attachment,
            generate_outgoing_receipt: nil,
            generate_incoming_receipts: nil
          ) 
        }

        before do
          User.stub(:find_by_user_name).with(user.user_name).and_return(user)
          user.stub(:create_attached_message).and_return(message)
          Pusher.stub(:push_message).with(message)
        end

        it "creates a message with attachment belonging to the given user" do
          user.should_receive(:create_attached_message).with(payload).and_return(message)
          post :create, params
        end

        it "generates the message outgoing receipt" do
          message.should_receive(:generate_outgoing_receipt)
          post :create, params
        end

        it "generates the message incoming receipts" do
          message.should_receive(:generate_incoming_receipts)
          post :create, params
        end

        it "pushes the message" do
          Pusher.should_receive(:push_message).with(message)
          post :create, params
        end

        it 'renders the create template' do
          post :create, params
          expect(response).to render_template(:create)
        end
      end

      context "with invalid parameters" do

        let(:message) { double('message', attachment: nil) }

        before { user.stub(:create_attached_message).and_return(message) }

        it "does not push a message" do
          Pusher.should_not_receive(:push_message)
          post :create, params
        end
      end
    end

    context "for unauthorized users" do

      before { controller.stub(:current_user).and_return(double('unauthorized user')) }

      it "redirects to the sign_in page" do
        post :create, params
        expect(response).to redirect_to(signin_path)
      end

      it "renders a flash message" do
        post :create, params
        expect(flash[:notice]).to eq "Not Authorized"
      end
    end

    context "for unauthenticated users" do

      before { controller.stub(:current_user).and_return(nil) }

      it "redirects to the sign_in page" do
        post :create, params
        expect(response).to redirect_to(signin_path)
      end

      it "renders a flash message" do
        get :index, user_id: user
        expect(flash[:notice]).to eq 'Please sign in to access this page.'
      end
    end
  end

  describe 'GET index' do

    context 'for authenticated and authorized users' do

      let(:user) { double('user', user_name: 'jack', to_param: 'jack') }

      before do
        controller.stub(:current_user).and_return(user)
        User.stub(:find_by_user_name).with(user.user_name).and_return(user)
      end

      context "format json" do

        let(:attr1) {{ payload_identifier: 'CUSS_yard_plan.xls',
                       payload_url: 'uploads/attachments/CUSS_yard_plan.xls',
                       id: 22
        }}
        let(:attr2) {{ payload_identifier: 'CUSS_yard_plan.xls',
                       payload_url: 'uploads/attachments/CUSS_yard_plan.xls',
                       id: 23
        }}
        let(:attachment1) { double('attachment1', as_json: attr1) }
        let(:attachment2) { double('attachment2', as_json: attr2) }
        let(:attachments) { [attachment1, attachment2] }

        before do
          Attachment.stub(:for_user).with(user).and_return(attachments)
        end

        it "renders the user's attachments as json" do
          get :index, user_id: user, format: :json
          expect(response.body).to eq ({ "attachments" => attachments }.to_json)
        end
      end

      context "format html" do

        before do
          user.stub(:handle).and_return('bill@CUSN')
        end

        it "assigns the current user's handle to @handle" do
          get :index, user_id: user, format: :html
          expect(assigns(:handle)).to eq('bill@CUSN')
        end

        it "assigns the page's title to @title" do
          get :index, user_id: user, format: :html
          expect(assigns(:title)).to eq('Files for bill@CUSN')
        end

        it "renders the index template" do
          get :index, user_id: user, format: :html
          expect(response).to render_template(:index)
        end
      end
    end

    context 'for unauthorized users' do

      before do
        controller.stub(:current_user).and_return(double('unauthorized user'))
        User.stub(:find_by_user_name).with(user.user_name).and_return(user)
      end

      it "redirects to the signin page" do
        get :index, user_id: user
        expect(response).to redirect_to signin_path
      end

      it "renders a flash message" do
        get :index, user_id: user
        expect(flash[:notice]).to eq 'Not Authorized'
      end
    end

    context 'for unauthenticated users' do

      before { controller.stub(:current_user).and_return(nil) }

      it 'redirects to the signin page' do
        get :index, user_id: 'user'
        response.should redirect_to(signin_path)
      end

      it "renders a flash message" do
        get :index, user_id: user
        expect(flash[:notice]).to eq 'Please sign in to access this page.'
      end
    end
  end
end
