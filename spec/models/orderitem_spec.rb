# == Schema Information
#
# Table name: orderitems
#
#  id         :integer          not null, primary key
#  order_id   :integer
#  user_id    :integer
#  item_id    :integer
#  created_at :datetime
#  updated_at :datetime
#  quantity   :integer          default(1)
#

require 'spec_helper'

describe Orderitem do
  pending "add some examples to (or delete) #{__FILE__}"
end
