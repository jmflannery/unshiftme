require 'spec_helper'

describe TranscriptsController do

  let(:user) {
    double('user', {
      id: 42,
      user_name: 'bob',
      to_param: 'bob',
      handle: 'bob@CUSS',
      admin?: true,
      transcripts: double('transcripts')
    })
  }

  describe "GET new" do

    let(:params) {{ user_id: user }}

    context "for unauthenticated users" do

      before(:each) { controller.stub(:current_user).and_return(nil) }

      it "redirects to the sign_in path'" do
        get :new, params
        response.should redirect_to(signin_path)
      end
    end

    context "for authenticated but unauthorized users" do

      let(:current_user) { double('user', to_param: 'juice') }
      before(:each) do
        controller.stub(:current_user).and_return(current_user)
        User.stub(:find_by_user_name).with(user.user_name).and_return(user)
      end

      it "redirects to the current user's path" do
        get :new, params
        response.should redirect_to(user_path(current_user))
      end
    end

    context "for users authenticated and authorized but not admins" do

      before(:each) do
        controller.stub(:current_user).and_return(user)
        User.stub(:find_by_user_name).with(user.user_name).and_return(user)
        user.stub(:admin?).and_return(false)
      end

      it "redirects to the user's path" do
        get :new, params
        response.should redirect_to(user_path(user))
      end
    end

    context "for authenticated and authorized admin users" do

      before(:each) do
        user.stub(admin?: true)
        controller.stub(:current_user).and_return(user)
        User.stub(:find_by_user_name).with(user.user_name).and_return(user)
      end

      it "finds the correct user" do
        User.should_receive(:find_by_user_name).with(user.user_name).and_return(user)
        post :new, params
      end

      it "creates and assigns a new Transcript to @transcript" do
        Transcript.should_receive(:new).and_return(t = double('transcript'))
        get :new, params
        expect(assigns(:transcript)).to eq t
      end

      it "assigns the page's title to @title" do
        get :new, params
        expect(assigns(:title)).to eq "New Transcript"
      end

      it "assigns the current user's handle to @handle" do
        get :new, params
        expect(assigns(:handle)).to eq "bob@CUSS"
      end

      it "gets all workstations abrevs in an Array with a leading empty string" do
        workstations = double('workstations').as_null_object
        Workstation.should_receive(:all_short_names).and_return(workstations)
        workstations.should_receive(:unshift).with("")
        get :new, params
      end

      it "gets all User names in an Array with a leading empty string" do
        users = double('users').as_null_object
        User.should_receive(:all_user_names).and_return(users)
        users.should_receive(:unshift).with("")
        get :new, params
      end
    end
  end

  describe "POST create" do

    let(:params) {{ user_id: user, transcript: {} }}

    context "for unauthenticated users" do

      before(:each) { controller.stub(:current_user).and_return(nil) }

      it "redirects to the sign_in path" do
        post :create, params
        response.should redirect_to(signin_path)
      end
    end

    context "for authenticated but unauthorized users" do

      let(:current_user) { double('user', to_param: 'juice') }
      before(:each) do
        controller.stub(:current_user).and_return(current_user)
        User.stub(:find_by_user_name).with(user.user_name).and_return(user)
      end

      it "redirects to the current user's path" do
        post :create, params
        response.should redirect_to(user_path(current_user))
      end
    end

    context "for authenticated and authorized but non-admin users" do

      before(:each) do
        controller.stub(:current_user).and_return(user)
        User.stub(:find_by_user_name).with(user.user_name).and_return(user)
        user.stub(:admin?).and_return(false)
      end

      it "redirects to the user's path" do
        post :create, params
        response.should redirect_to(user_path(user))
      end
    end

    context "for authenticated and authorized admin users" do

      let(:transcript) { double('transcript', save: nil) }
      before(:each) do
        User.stub(:find_by_user_name).with(user.user_name).and_return(user)
        user.stub(admin?: true)
        controller.stub(:current_user).and_return(user)
      end

      context "with a transcript user given" do

        before(:each) do
          params.merge!(transcript: { transcript_user_id: 'bob' })
          User.stub(:find_by_user_name).with(user.user_name).and_return(user)
        end

        it "builds a transcript" do
          user.transcripts.should_receive(:build).and_return(transcript)
          post :create, params
        end

        context "save failure" do

          before { transcript.stub(save: false) }

          it "redirects to the new transcript path" do
            user.transcripts.stub(:build).and_return(transcript)
            post :create, params
            response.should redirect_to new_user_transcript_path(user)
          end
        end

        context "save success" do

          before { transcript.stub(save: true, to_param: '32') }

          it "redirects to the transcript_path(transcript) path" do
            user.transcripts.stub(:build).and_return(transcript)
            post :create, params
            response.should redirect_to user_transcript_path(user, transcript)
          end
        end
      end

      context "without a transcript user" do

        before(:each) do
          User.stub(:find_by_user_name).with(nil).and_return(nil)
        end

        it "redirects back to the new transcript path" do
          post :create, params
          expect(response).to redirect_to new_user_transcript_path(user)
        end

        it "has a flash message" do
          post :create, params
          expect(flash[:notice]).to eq "Must choose a User"
        end
      end
    end
  end

  describe "GET show" do

    # should transcript id be string or fixnum??
    let(:transcript) { double('transcript', id: '22', to_param: 22, transcript_user_id: 24, name: 'my transcript') }
    let(:params) {{ user_id: user, id: transcript }}

    context "for unauthenticated users" do

      before(:each) { controller.stub(:current_user).and_return(nil) }

      it "redirects to the sign_in path" do
        get :show, params
        response.should redirect_to(signin_path)
      end

      it "has a flash message" do
        get :show, params
        expect(flash[:notice]).to eq "Please sign in to access this page."
      end
    end

    context "for users authenticated but unauthorized to view the users resources" do

      let(:current_user) { double('user', to_param: 'juice') }
      before(:each) do
        controller.stub(:current_user).and_return(current_user)
        User.stub(:find_by_user_name).with(user.user_name).and_return(user)
      end

      it "redirects to the current user's path" do
        get :show, params
        response.should redirect_to(user_path(current_user))
      end

      it "has a flash message" do
        get :show, params
        expect(flash[:notice]).to eq "Not authorized to view this user's transcripts"
      end
    end

    context "for users authenticated but not authorized to view the transcript" do

      before(:each) do
        controller.stub(:current_user).and_return(user)
        User.stub(:find_by_user_name).with(user.user_name).and_return(user)
        user.transcripts.stub(:find_by_id).with(transcript.id).and_return(nil)
      end

      it "redirects to the current user's path" do
        get :show, params
        expect(response).to redirect_to(user_path(user))
      end

      it "has a flash message" do
        get :show, params
        expect(flash[:notice]).to eq "Not authorized to view this transcript"
      end
    end

    context "for users authenticated but not admins" do

      before(:each) do
        controller.stub(:current_user).and_return(user)
        User.stub(:find_by_user_name).with(user.user_name).and_return(user)
        user.transcripts.stub(:find_by_id).with(transcript.id).and_return(transcript)
        user.stub(:admin?).and_return(false)
      end

      it "redirects to the user's path" do
        get :show, params
        response.should redirect_to(user_path(user))
      end

      it "has a flash notice" do
        get :show, params
        expect(flash[:notice]).to eq "Must be an administrator to access transcripts"
      end
    end

    context "for authenticated and authorized admin users" do

      before(:each) do
        controller.stub(:current_user).and_return(user)
        User.stub(:find_by_user_name).with(user.user_name).and_return(user)
        transcript.stub(:transcript_user).and_return(222)
      end

      context "format json" do

        before(:each) do
          # why do get a fixnum here, others get string
          user.transcripts.stub(:find_by_id).with(transcript.id.to_i).and_return(transcript)
        end

        it "renders the transcript as json" do
          transcript.should_receive(:as_json).with(any_args)
          controller.should_receive(:render).twice
          params.merge!(format: :json)
          get :show, params
        end
      end

      context 'format html' do

        before(:each) do
          user.transcripts.stub(:find_by_id).with(transcript.id).and_return(transcript)
        end

        it "assigns the page title to @title" do
          get :show, params
          expect(assigns(:title)).to eq transcript.name
        end

        it "assigns the current_user's handle to @handle" do
          get :show, params
          expect(assigns(:handle)).to eq user.handle
        end
      end
    end
  end

  describe "GET index" do

    let(:params) {{ user_id: user }}

    context "for unauthenticated users" do

      before(:each) { controller.stub(:current_user).and_return(nil) }

      it "redirects to the sign_in path'" do
        get :index, params
        response.should redirect_to(signin_path)
      end

      it "has a flash message" do
        get :index, params
        expect(flash[:notice]).to eq "Please sign in to access this page."
      end
    end

    context "for users authenticated but unauthorized to view the users resources" do

      let(:current_user) { double('user', to_param: 'juice') }
      before(:each) do
        controller.stub(:current_user).and_return(current_user)
        User.stub(:find_by_user_name).with(user.user_name).and_return(user)
      end

      it "redirects to the current user's path" do
        get :index, params
        response.should redirect_to(user_path(current_user))
      end

      it "has a flash message" do
        get :index, params
        expect(flash[:notice]).to eq "Not authorized to view this user's transcripts"
      end
    end

    context "for users authenticated but not admins" do

      before(:each) do
        controller.stub(:current_user).and_return(user)
        User.stub(:find_by_user_name).with(user.user_name).and_return(user)
        user.stub(:admin?).and_return(false)
      end

      it "redirects to the user's path" do
        get :index, params
        response.should redirect_to(user_path(user))
      end

      it "has a flash notice" do
        get :index, params
        expect(flash[:notice]).to eq "Must be an administrator to access transcripts"
      end
    end

    context "for authenticated and authorized admin users" do

      before(:each) do
        controller.stub(:current_user).and_return(user)
        User.stub(:find_by_user_name).with(user.user_name).and_return(user)
        user.transcripts.stub(size: 5)
      end

      it "assigns the current user's handle to @handle" do
        get :index, params
        expect(assigns(:handle)).to eq user.handle
      end

      it "assigns the page title to @title" do
        get :index, params
        expect(assigns(:title)).to eq "#{user.user_name}'s Transcripts"
      end

      it "gets current user's transcripts and assignes to @transcripts" do
        transcripts = double('transcripts')
        user.should_receive(:transcripts).and_return(transcripts)
        get :index, params
        expect(assigns(:transcripts)).to eq transcripts
      end

      it "gets a count of the current user's transcripts and assigns to @transcript_count" do
        user.transcripts.should_receive(:size).and_return(320)
        get :index, params
        expect(assigns(:transcript_count)).to eq 320
      end
    end
  end

  describe "DELETE destroy" do

    let(:transcript) { double('transcript', id: 22, to_param: 22, transcript_user_id: 24, name: 'my transcript') }
    let(:params) {{ user_id: user, id: transcript, format: :js }}

    context "for unauthenticated users" do

      before(:each) { controller.stub(:current_user).and_return(nil) }

      it "redirects to the sign_in path" do
        delete :destroy, params
        response.should redirect_to(signin_path)
      end

      it "has a flash message" do
        delete :destroy, params
        expect(flash[:notice]).to eq "Please sign in to access this page."
      end
    end

    context "for users authenticated but unauthorized to view the users resources" do

      let(:current_user) { double('user', to_param: 'juice') }
      before(:each) do
        controller.stub(:current_user).and_return(current_user)
        User.stub(:find_by_user_name).with(user.user_name).and_return(user)
      end

      it "redirects to the current user's path" do
        delete :destroy, params
        response.should redirect_to(user_path(current_user))
      end

      it "has a flash message" do
        delete :destroy, params
        expect(flash[:notice]).to eq "Not authorized to view this user's transcripts"
      end
    end

    context "for users authenticated but not authorized to view the transcript" do

      before(:each) do
        controller.stub(:current_user).and_return(user)
        User.stub(:find_by_user_name).with(user.user_name).and_return(user)
        user.transcripts.stub(:find_by_id).with(transcript.id).and_return(nil)
      end

      it "redirects to the current user's path" do
        delete :destroy, params
        expect(response).to redirect_to(user_path(user))
      end

      it "has a flash message" do
        delete :destroy, params
        expect(flash[:notice]).to eq "Not authorized to view this transcript"
      end
    end

    context "for users authenticated but not admins" do

      before(:each) do
        controller.stub(:current_user).and_return(user)
        User.stub(:find_by_user_name).with(user.user_name).and_return(user)
        user.transcripts.stub(:find_by_id).with(transcript.id).and_return(transcript)
        user.stub(:admin?).and_return(false)
      end

      it "redirects to the user's path" do
        delete :destroy, params
        response.should redirect_to(user_path(user))
      end

      it "has a flash notice" do
        delete :destroy, params
        expect(flash[:notice]).to eq "Must be an administrator to access transcripts"
      end
    end

    context "for authenticated and authorized admin users" do

      before(:each) do
        controller.stub(:current_user).and_return(user)
        User.stub(:find_by_user_name).with(user.user_name).and_return(user)
        user.transcripts.stub(:find_by_id).with(transcript.id).and_return(transcript)
        user.transcripts.stub(size: 5)
      end

      it "deletes the transcript" do
        transcript.should_receive(:destroy).with(no_args)
        delete :destroy, params
      end

      it "gets the new transcript count and assigns to @transcript_count" do
        transcript.stub(:destroy)
        user.transcripts.should_receive(:size).and_return(543)
        delete :destroy, params
        expect(assigns(:transcript_count)).to eq 543
      end
    end
  end
end
