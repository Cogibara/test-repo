# Change this file to be a wrapper around your daemon code.

# Do your post daemonization configuration here
# At minimum you need just the first line (without the block), or a lot
# of strange things might start happening...

DaemonKit::Application.running! do |config|
  # Trap signals with blocks or procs
  # config.trap( 'INT' ) do
  #   # do something clever
  # end
  # config.trap( 'TERM', Proc.new { puts 'Going down' } )
end

DaemonKit::XMPP.run do
  when_ready { DaemonKit.logger.info "Connected as #{jid}" }

  # Auto approve subscription requests
  subscription :request? do |s|
    write_to_stream s.approve!
  end

  # Echo back what was said
  message :chat?, :body do |m|
    # repl = Cogi.ask(m.body)
    DaemonKit.logger.info "got #{m}"
    msg = m.reply
    msg.body = Cogi.ask_xmpp(m)

    write_to_stream msg
    # write_to_stream m.reply
    # write_to_stream Blather::Stanza::Message.new "dafux"
  end
end