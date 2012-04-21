require 'spec_helper'

feature "Message Acknowledgement", js: true do
  background do
    @message = "this be my message, dummy"
    @add_users_button_text = "Add Available Users"

    within_browser(:reciever) do
      @reciever = request_sign_in(FactoryGirl.create(:user))
    end

    within_browser(:sender) do
      @sender = request_sign_in(FactoryGirl.create(:user1))
      within("#recipient_selection_section") do
        click_link @add_users_button_text
        click_link @reciever.user_name
      end
      request_send_message(@message)
    end
  end

  scenario "Acknowleding a recieved message" do
    within_browser(:reciever) do
      within "#messages_section" do
        #page.should have_css("li.message.recieved")
        find("li.message.recieved.unread").click
      end
    end

    within_browser(:sender) do
      within "#messages_section li.message.owner" do
        page.should have_content("#{@reciever.user_name} read this.")
      end
    end
  end
end
