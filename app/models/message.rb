class Message < ApplicationRecord
  acts_as_message
  has_many_attached :attachments

  broadcasts_to ->(message) { "chat_#{message.chat_id}" }, inserts_by: :append

  def broadcast_append_chunk(content)
    broadcast_append_to "chat_#{chat_id}",
      target: "message_#{id}_content",
      content: ERB::Util.html_escape(content.to_s)
  end
end
