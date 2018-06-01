#******************************************************************************
# ALX - Skies of Arcadia Legends Examiner
# Copyright (C) 2018 Marcel Renner
# 
# This file is part of ALX.
# 
# ALX is free software: you can redistribute it and/or modify it under the 
# terms of the GNU General Public License as published by the Free Software 
# Foundation, either version 3 of the License, or (at your option) any later 
# version.
# 
# ALX is distributed in the hope that it will be useful, but WITHOUT ANY 
# WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS 
# FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more 
# details.
# 
# You should have received a copy of the GNU General Public License along with 
# ALX. If not, see <http://www.gnu.org/licenses/>.
#******************************************************************************

#==============================================================================
#                                 REQUIREMENTS
#==============================================================================

require_relative('effectable.rb')
require_relative('stdentry.rb')

# -- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --

module ALX

#==============================================================================
#                                    CLASS
#==============================================================================

# Class to handle a shop.
class Shop < StdEntry
  
#==============================================================================
#                                   INCLUDES
#==============================================================================

  include(Effectable)

#==============================================================================
#                                   PUBLIC
#==============================================================================

  public

  # Constructs a Shop.
  # @param _region [String] Region ID
  def initialize(_region)
    super
    @items = {}

    members.clear
    members << IntVar.new(CsvHdr::ID              ,  0, 'S>')
    members << IntVar.new(padding_hdr             ,  0, 's>')
    members << IntVar.new(CsvHdr::MESSAGE_ID      ,  0, 'L>')

    add_dscr_members
    
    (1..48).each do |_i|
      members << IntVar.new(CsvHdr::ITEM_ID[_i]   , -1, 's>')
      members << StrDmy.new(CsvHdr::ITEM_NAME[_i] , ''      )
    end
  end

  # Writes one entry to a CSV file.
  # @param _f [CSV] CSV object
  def write_to_csv(_f)
    (1..48).each do |_i|
      _id = find_member(CsvHdr::ITEM_ID[_i]).value
      if _id != -1
        _entry = @items[_id]
        _name  = '???'
        if _entry
          case region
          when 'E'
            _name = _entry.find_member(CsvHdr::NAME_US_STR).value
          when 'J'
            _name = _entry.find_member(CsvHdr::NAME_JP_STR).value
          when 'P'
            _name = _entry.find_member(CsvHdr::NAME_GB_STR).value
          end
        end
      else
        _name = 'None'
      end
      find_member(CsvHdr::ITEM_NAME[_i]).value = _name
    end
    
    super
  end

#------------------------------------------------------------------------------
# Public member variables
#------------------------------------------------------------------------------

  attr_accessor :items

end	# class Shop

# -- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --

end	# module ALX