# = Informations
# 
# == License
# 
# Ekylibre - Simple ERP
# Copyright (C) 2009-2010 Brice Texier, Thibaud Merigon
# 
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# any later version.
# 
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
# 
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see http://www.gnu.org/licenses.
# 
# == Table: stock_transfers
#
#  comment              :text             
#  company_id           :integer          not null
#  created_at           :datetime         not null
#  creator_id           :integer          
#  id                   :integer          not null, primary key
#  lock_version         :integer          default(0), not null
#  moved_on             :date             
#  nature               :string(8)        not null
#  number               :string(64)       not null
#  planned_on           :date             not null
#  product_id           :integer          not null
#  quantity             :decimal(16, 4)   not null
#  second_stock_move_id :integer          
#  second_warehouse_id  :integer          
#  stock_move_id        :integer          
#  tracking_id          :integer          
#  unit_id              :integer          
#  updated_at           :datetime         not null
#  updater_id           :integer          
#  warehouse_id         :integer          not null
#


class StockTransfer < CompanyRecord
  acts_as_numbered
  acts_as_stockable :quantity=>'-self.quantity'
  acts_as_stockable :second_stock_move, :warehouse=>'self.second_warehouse', :if=>'self.transfer? '

  attr_readonly :company_id, :nature
  belongs_to :company
  belongs_to :product
  belongs_to :warehouse
  belongs_to :second_stock_move, :class_name=>"StockMove"
  belongs_to :second_warehouse, :class_name=>Warehouse.to_s
  belongs_to :stock_move
  belongs_to :tracking
  belongs_to :unit
  validates_presence_of :unit
  validates_presence_of :second_warehouse, :if=>Proc.new{|x| x.transfer?}
  validates_numericality_of :quantity, :greater_than=>0.0

  before_validation do
    self.unit_id = self.product.unit_id if self.product
    if self.planned_on
      self.moved_on = Date.today if self.planned_on <= Date.today
    end
    self.second_warehouse_id = nil unless self.transfer? # if self.nature == "waste"
  end

  validate do
    if self.tracking
      errors.add(:tracking_id, :invalid) if self.tracking.product_id != self.product_id
    end
    if self.unit
      errors.add(:unit_id, :invalid) unless self.unit.convertible_to? self.product.unit
    end
    if !self.second_warehouse.nil?
      errors.add_to_base(:warehouse_can_not_receive_product, :warehouse=>self.second_warehouse.name, :product=>self.product.name, :contained_product=>self.second_warehouse.product.name) unless self.second_warehouse.can_receive(self.product_id)
    end
    unless self.warehouse.can_receive(self.product_id)
      errors.add_to_base(:warehouse_can_not_transfer_product, :warehouse=>self.warehouse.name, :product=>self.product.name, :contained_product=>self.warehouse.product.name) if self.nature=="transfer"
      errors.add_to_base(:warehouse_can_not_waste_product, :warehouse=>self.warehouse.name, :product=>self.product.name, :contained_product=>self.warehouse.product.name) if self.nature=="waste"
    end
    errors.add_to_base(:warehouses_can_not_be_identical) if self.warehouse_id == self.second_warehouse_id 
  end
  
  def self.natures
    [:transfer, :waste].collect{|x| [tc('natures.'+x.to_s), x] }
  end


  def text_nature
    tc('natures.'+self.nature.to_s)
  end

  def transfer?
    self.nature.to_s == "transfer"
  end

  
  def execute(moved_on = Date.today)
    StockTransfer.transaction do
      self.update_attributes(:moved_on => moved_on)
    end
  end
  
end
