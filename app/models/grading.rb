# = Informations
#
# == License
#
# Ekylibre - Simple agricultural ERP
# Copyright (C) 2008-2009 Brice Texier, Thibaud Merigon
# Copyright (C) 2010-2012 Brice Texier
# Copyright (C) 2012-2016 Brice Texier, David Joulin
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU Affero General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Affero General Public License for more details.
#
# You should have received a copy of the GNU Affero General Public License
# along with this program.  If not, see http://www.gnu.org/licenses.
#
# == Table: gradings
#
#  comment                :text
#  created_at             :datetime         not null
#  creator_id             :integer
#  id                     :integer          not null, primary key
#  implanter_lines_gap    :decimal(19, 4)
#  implanter_lines_number :integer
#  lock_version           :integer          default(0), not null
#  number                 :string           not null
#  product_id             :integer          not null
#  sampled_at             :datetime         not null
#  updated_at             :datetime         not null
#  updater_id             :integer
#

class Grading < Ekylibre::Record::Base
  belongs_to :product
  # [VALIDATORS[ Do not edit these lines directly. Use `rake clean:validations`.
  validates_datetime :sampled_at, allow_blank: true, on_or_after: -> { Time.new(1, 1, 1).in_time_zone }, on_or_before: -> { Time.zone.now + 50.years }
  validates_numericality_of :implanter_lines_number, allow_nil: true, only_integer: true
  validates_numericality_of :implanter_lines_gap, allow_nil: true
  validates_presence_of :number, :product, :sampled_at
  # ]VALIDATORS]

end
