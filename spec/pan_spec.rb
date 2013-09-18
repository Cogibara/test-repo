require File.dirname(__FILE__) + '/spec_helper.rb'

# Time to add your specs!
# http://rspec.info/
describe Cogibara do

  it "defaults to chatting" do
    VCR.use_cassette('chatbot') do
      # puts "hello?"
      Cogi.ask_local('hello?').should ==  "What's your name?"
      Cogi.ask_local('Who are you').should == "A person who's having a nice conservation with you."

    end
  end

  it "can return raw question objects" do
    VCR.use_cassette('chatbot') do
      msg = Cogi.ask('hello?',from: "wstrinz@gmail.com")
      msg.to.should == "wstrinz@gmail.com"
      msg.from.should == "cogibara"
    end
  end

  it "has a memory" do
    VCR.use_cassette('chatbot') do
      Cogibara.dump_memory["What's your name"].should_not be nil
    end
  end

  it "can send xmpp response" do
    VCR.use_cassette('chatbot') do
      msg = Blather::Stanza::Message.new
      msg.body = "hello?"
      msg.type = :chat
      msg.id = 1234
      Cogi.ask_xmpp(msg).should == "What's your name?"
    end
  end

  describe "Adding new modules" do
    class Reverser < Cogibara::Module
      def ask(msg)
        msg.message.reverse
      end
    end

    before do
      Reverser.register
    end

    it { Cogi.ask_local('hello?').should ==  "?olleh" }
  end
end
