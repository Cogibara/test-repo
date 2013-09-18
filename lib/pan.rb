# Your starting point for daemon specific classes. This directory is
# already included in your load path, so no need to specify it.


# This is the top level of the thinking part... yeah
# some class methods for convenience





class Cogibara
  class Module
    def self.register
      Cogibara.modules.unshift self.new
    end
  end

  def self.onto
    RDF::Vocabulary.new('http://onto.cogibara.com/')
  end

  def self.onto_class
    RDF::Vocabulary.new('http://onto.cogibara.com/classes/')
  end

  def self.onto_prop
    RDF::Vocabulary.new('http://onto.cogibara.com/properties/')
  end

  # eventuall this should be a wrapper for a spira class, so its
  # method list and interaction is less complicated for now SW ppl
  class Message < Spira::Base
    configure base_uri: 'http://cogi.strinz.me/messages/'

    property :message, predicate: Cogibara.onto_prop.message_string
    property :response, predicate: Cogibara.onto_prop.response_to, type: RDF::URI
    property :from, predicate: Cogibara.onto_prop.from_user, type: String
    property :to, predicate: Cogibara.onto_prop.to_user, type: String
    property :message_id, predicate: Cogibara.onto_prop.message_id

    def to_s
      self.subject.to_s
    end
  end

  class Memory

    PREFIXES = {
      prop: "http://onto.cogibara.com/properties/",
      message: 'http://cogi.strinz.me/messages/',
      cogi_class: 'http://onto.cogibara.com/classes/',
    }

    def dump_memory
      RDF::Turtle::Writer.buffer(:prefixes => PREFIXES) do |writer|
        repo.each_statement do |statement|
          writer << statement
        end
      end
      # repo.to_ttl(prefixes: PREFIXES)
    end

    def self.repo
      Cogibara.base_cogi.repo
    end

    def self.new_message(msg,opts={})
      Cogibara.base_cogi.repo.new_message(msg,opts)
    end

    def default_opts
      {
        id: new_id,
      }
    end

    def repo
      @repo ||= RDF::Repository.new
    end

    def new_message(msg,opts={})
      opts = default_opts.merge(opts)
      msg_uri = RDF::URI.new("http://cogi.strinz.me/messages/#{opts[:id]}")
      mem = repo
      mem.insert([msg_uri, RDF.type, Cogibara.onto_class.Message])
      mem.insert([msg_uri, Cogibara.onto_prop.message_string, msg])
      mem.insert([msg_uri, Cogibara.onto_prop.message_id, opts[:id]]) if opts[:id]
      mem.insert([msg_uri, Cogibara.onto_prop.from_user, opts[:from]]) if opts[:from]
      mem.insert([msg_uri, Cogibara.onto_prop.to_user, opts[:to]]) if opts[:to]
      Cogibara::Message.for(msg_uri)
    end

    def new_id
      #Maybe use uuid gem eventually?
      "#{Time.now.nsec}_#{rand(1000)}"
    end
  end

  def self.modules
    base_cogi.modules
  end

  def self.dump_memory
    memory.dump_memory
  end

  def self.memory
    @@memory ||= base_cogi.memory
  end

  def self.base_cogi
    @@base_cogi ||= Cogibara.new
  end

  def self.ask(message)
    base_cogi.ask(message)
  end

  def modules
    @modules ||= []
  end

  def memory
    @memory ||= Memory.new
  end

  def ask(message)
    # "Hello #{message.message}"

    modules.each do |mod|
      response = mod.ask(message)
      if response.is_a? String
        response = memory.new_message(response)
        message.response = response
        response.from = "cogibara"
        response.to = message.from
        message.save
        response.save
        return response
      elsif response.is_a? Symbol
        raise "received code #{response} from #{mod}"
      elsif response.is_a? Cogibara::Message
        puts "pass along messages or return new ones"
      end
    end
  end
end

class Chatbot < Cogibara::Module
  require 'cleverbot'
  def ask(message)
    @cleverbot ||= Cleverbot::Client.new
    @cleverbot.write message.message
  end

  register
end


# Interface to XMPP communications
# - Eventually have this handle the different
#     protocols, communications methods, etc.
#     EG voice input?

# Sould also rename class eventually

class Cogi

  def self.ask(msg,opts={})
    # msg =
    Cogibara.ask Cogibara.memory.new_message(msg, opts)
  end

  def self.ask_xmpp(msg)
    msg = ask msg.body, id: msg.id, from: msg.from
    msg.message
  end

  # plain string; generate message id
  def self.ask_local(string)
    msg = ask(string, from: "local")
    msg.message
  end

end

