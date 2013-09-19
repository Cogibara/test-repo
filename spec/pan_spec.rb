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
      original = msg.response_to
      original.response.subject.should == msg.subject
      # resp.is_a?(Cogibara::Message).should be true
      # resp.response_to.should == msg
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

    context "overriding ask method" do
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

    context "using the dsl" do
      describe "use on keyword and strings or regexps to define behavior" do
        class DiceRoller < Cogibara::Module
          on 'hello you' do
            "hai dere"
          end

          on %r{^I'm (.+)} do |name|
            "hi #{name}"
          end

          on(/roll me (\d+)d(\d+)/) do |number,size|
            number.to_i.times.map{|t| rand(size.to_i)+1 }.join("\n")
          end
        end

        before do
          DiceRoller.register
        end

        it { Cogi.ask_local('hello you').should ==  "hai dere" }
        it { Cogi.ask_local("I'm bill").should ==  "hi bill" }
        it { Cogi.ask_local("roll me 1d150").to_i.should > 0  }
        it { Cogi.ask_local("roll me 4d20").split("\n").size.should == 4 }
      end

      describe "can still access the raw message" do
        class CreepyGreeter < Cogibara::Module
          on(/.*/) do
            "hehe... hello #{current_message.from}"
          end
        end

        before do
          CreepyGreeter.register
        end

        it { Cogi.ask_local('hellow').should ==  "hehe... hello local" }
      end
    end

  end
end
