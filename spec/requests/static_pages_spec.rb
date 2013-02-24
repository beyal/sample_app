require 'spec_helper'

describe "Static pages" do

  subject { page }

  shared_examples_for "all static pages" do
    it { should have_selector('h1',    text: heading) }
    it { should have_selector('title', text: full_title(page_title)) }
  end

  describe "Home page" do
    before { visit root_path }
    let(:heading)    { 'Friggo' }
    let(:page_title) { '' }

    it_should_behave_like "all static pages"
    it { should_not have_selector 'title', text: '| How It Works' }

    describe "for signed-in users" do
      let(:user) { FactoryGirl.create(:user) }
      before do
        FactoryGirl.create(:micropost, user: user, content: "Lorem ipsum")
        FactoryGirl.create(:micropost, user: user, content: "Dolor sit amet")
        sign_in user
        visit root_path
      end

      it "should render the user's feed" do
        user.feed.each do |item|
          page.should have_selector("li##{item.id}", text: item.content)
        end
      end

      describe "follower/following counts" do
        let(:other_user) { FactoryGirl.create(:user) }
        before do
          other_user.follow!(user)
          visit root_path
        end

        it { should have_link("0 following", href: following_user_path(user)) }
        it { should have_link("1 followers", href: followers_user_path(user)) }
      end

      describe "user should not be able to see delete links of other users microposts" do
        let(:user2) { FactoryGirl.create(:user) }
        let!(:m1) { FactoryGirl.create(:micropost, user: user2, content: "Foo") }

        before do
          visit root_path
        end

        it { should_not have_selector('href', text: m1.content) }
      end   
    end    
  end

  describe "FAQ page" do
    before { visit help_path }
    let(:heading)    { 'FAQ' }
    let(:page_title) { 'FAQ' }

    it_should_behave_like "all static pages"
  end

  describe "About page" do
    before { visit about_path }
    let(:heading)    { 'About' }
    let(:page_title) { 'About' }

    it_should_behave_like "all static pages"
  end

  describe "Contact page" do
    before { visit contact_path }
    let(:heading)    { 'Contact' }
    let(:page_title) { 'Contact' }

    it_should_behave_like "all static pages"
  end

  it "should have the right links on the layout" do
    visit root_path
    click_link "About"
    page.should have_selector 'title', text: full_title('About Us')
    click_link "FAQ"
    page.should have_selector 'title', text: full_title('FAQ')
    click_link "Contact"
    page.should have_selector 'title', text: full_title('Contact')
    click_link "Friggo"
    click_link "Start Selling Now!"
    page.should have_selector 'title', text: full_title('Sign up')
    click_link "How It Works"
    page.should have_selector 'title', text: full_title('')
  end
end
