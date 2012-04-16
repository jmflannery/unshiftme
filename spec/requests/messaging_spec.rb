require 'spec_helper'

describe "Messaging" do

  before(:each) do
    @add_users_button_text = "Add Available Users"
  end
  
  describe "sending a message" do
    
    before(:each) do
      @sender = Factory(:user)
      @message = "this is a message, wassup"
    end
    
    describe "in the senders browser" do

      before(:each) do
        within_browser(:sender) do
          request_sign_in(@sender)
          request_send_message(@message)
        end 
      end

      it "sends the message to the sender's browser", js: true do
        within_browser(:sender) do
          page.should have_selector("li.message.my_message", text: @message)
        end
      end

      it "clears the message input text field", js: true do
        within_browser(:sender) do
          find_field("message_content").value.should be_blank
        end
      end
    end

    describe "in the message recievers browser" do

      before(:each) do
        reciever = Factory(:user, name: "Jack", full_name: "Jack Sprat")

        within_browser(:reciever) do
          request_sign_in(reciever)
        end
        
        within_browser(:sender) do
          request_sign_in(@sender)
          within("#recipient_selection_section") do
            click_link @add_users_button_text
            click_link reciever.full_name
          end
          request_send_message(@message)
        end
      end
    
      it "sends the message to the sender's recipient's browser", js: true do
        within_browser(:reciever) do
          within "#messages_section" do
            page.should have_selector("li.message.recieved_message", text: @message)
          end
        end
      end

      it "adds the sender to the reciever's recipient list", js: true do
        within_browser :reciever do
          within "#send_to_section" do
            page.should have_selector("a.recipient_user", text: @sender.name)
          end
        end
      end
    end
  end
end
