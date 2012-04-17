require 'spec_helper'

feature "Message Acknowledgement", js: true do
  background do
    @message = "this be my message, dummy"
    @add_users_button_text = "Add Available Users"

    within_browser(:reciever) do
      @reciever = request_sign_in(Factory(:user, name: "Bill", full_name: "Bill Stump"))
    end

    within_browser(:sender) do
      @sender = request_sign_in(Factory(:user, name: "Jack", full_name: "Jack Sprat"))
      within("#recipient_selection_section") do
        click_link @add_users_button_text
        click_link @reciever.full_name
      end
      request_send_message(@message)
    end
  end

  scenario "Acknowleding a recieved message" do
    within_browser(:reciever) do
      within "#messages_section" do
        page.should have_css("li.message.recieved_message")
        #find("li.message.recieved_message").click
      end
    end

    within_browser(:sender) do
      within "#messages_section li.message.my_message" do
        page.should have_content("read by #{@reciever.name}")
      end
    end
  end
end
