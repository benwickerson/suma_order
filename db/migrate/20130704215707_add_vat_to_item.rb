class AddVatToItem < ActiveRecord::Migration
  def change
    add_column :items, :vat, :decimal
  end
end
