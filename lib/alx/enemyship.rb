#******************************************************************************
# ALX - Skies of Arcadia Legends Examiner
# Copyright (C) 2015 Marcel Renner
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

require_relative('dolentry.rb')
require_relative('effectable.rb')
require_relative('shipcannon.rb')

# -- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --

module ALX

#==============================================================================
#                                    CLASS
#==============================================================================

# Class to handle a enemy ship.
class EnemyShip < DolEntry
  
#==============================================================================
#                                   INCLUDES
#==============================================================================

  include(Effectable)
  
#==============================================================================
#                                  CONSTANTS
#==============================================================================

  # Drop IDs
  DROPS = Hash.new('???')
  DROPS.store(-1, 'None'  )
  DROPS.store( 0, '100%'  )
  DROPS.store( 2, '10%'   )
  DROPS.store( 3, '20%'   )
  DROPS.store( 4, '50%'   )
  DROPS.store( 6, 'Osman' )
  DROPS.store( 7, 'Kalifa')

#==============================================================================
#                                   PUBLIC
#==============================================================================

  public

  # Constructs a EnemyShip.
  # @param _region [String] Region ID
  def initialize(_region)
    super
    @item_data = {}
    add_name_members(20)
    
    members << IntVar.new(CsvHdr::MAXHP                   , -1, 'l>')
    members << IntVar.new(CsvHdr::WILL                    , -1, 's>')
    members << IntVar.new(CsvHdr::DEFENSE                 , -1, 's>')
    members << IntVar.new(CsvHdr::MAGDEF                  , -1, 's>')
    members << IntVar.new(CsvHdr::QUICK                   , -1, 's>')
    members << IntVar.new(CsvHdr::AGILE                   , -1, 's>')
    members << IntVar.new(CsvHdr::DODGE                   , -1, 's>')
    
    (0...6).each do |_i|
      members << IntVar.new(ELEMENTS[_i]                  , -1, 's>')
    end
    (1..4).each do |_i|
      if region == 'P'
        members << IntDmy.new(CsvHdr::ARM_NAME_DE_POS[_i] ,  0      )
        members << IntDmy.new(CsvHdr::ARM_NAME_DE_SIZE[_i],  0      )
        members << StrDmy.new(CsvHdr::ARM_NAME_DE_STR[_i] , '', '\n')
        members << IntDmy.new(CsvHdr::ARM_NAME_ES_POS[_i] ,  0      )
        members << IntDmy.new(CsvHdr::ARM_NAME_ES_SIZE[_i],  0      )
        members << StrDmy.new(CsvHdr::ARM_NAME_ES_STR[_i] , '', '\n')
        members << IntDmy.new(CsvHdr::ARM_NAME_FR_POS[_i] ,  0      )
        members << IntDmy.new(CsvHdr::ARM_NAME_FR_SIZE[_i],  0      )
        members << StrDmy.new(CsvHdr::ARM_NAME_FR_STR[_i] , '', '\n')
        members << IntDmy.new(CsvHdr::ARM_NAME_GB_POS[_i] ,  0      )
        members << IntDmy.new(CsvHdr::ARM_NAME_GB_SIZE[_i],  0      )
        members << StrDmy.new(CsvHdr::ARM_NAME_GB_STR[_i] , '', '\n')
      end
      members << IntVar.new(CsvHdr::ARM_TYPE_ID[_i]       , -1, 's>')
      members << StrDmy.new(CsvHdr::ARM_TYPE_NAME[_i]     , ''      )
      members << IntVar.new(CsvHdr::ARM_ATTACK[_i]        , -1, 's>')
      members << IntVar.new(CsvHdr::ARM_RANGE[_i]         , -1, 's>')
      members << IntVar.new(CsvHdr::ARM_HIT[_i]           , -1, 's>')
      members << IntVar.new(CsvHdr::ARM_ELEMENT_ID[_i]    , -1, 's>')
      members << StrDmy.new(CsvHdr::ARM_ELEMENT_NAME[_i]  , ''      )
    end

    members << IntVar.new(padding_hdr                     ,  0, 's>')
    members << IntVar.new(padding_hdr                     ,  0, 's>')
    members << IntVar.new(padding_hdr                     ,  0, 's>')
    members << IntVar.new(padding_hdr                     ,  0, 's>')
    members << IntVar.new(padding_hdr                     ,  0, 's>')
    members << IntVar.new(padding_hdr                     ,  0, 's>')
    members << IntVar.new(CsvHdr::EXP[0]                  , -1, 'l>')
    members << IntVar.new(CsvHdr::GOLD                    , -1, 'l>')

    (1..3).each do |_i|
      members << IntVar.new(CsvHdr::ITEM_DROP_ID[_i]      , -1, 's>')
      members << StrDmy.new(CsvHdr::ITEM_DROP_NAME[_i]    , ''      )
      members << IntVar.new(CsvHdr::ITEM_ID[_i]           , -1, 's>')
      members << StrDmy.new(CsvHdr::ITEM_NAME[_i]         , ''      )
    end
  end

  # Writes one entry to a CSV row.
  # @param _row [CSV::Row] CSV row
  def write_to_csv_row(_row)
    (1..4).each do |_i|
      _id   = find_member(CsvHdr::ARM_TYPE_ID[_i]).value
      find_member(CsvHdr::ARM_TYPE_NAME[_i]).value = ShipCannon::TYPES[_id]
      
      _id   = find_member(CsvHdr::ARM_ELEMENT_ID[_i]).value
      find_member(CsvHdr::ARM_ELEMENT_NAME[_i]).value = ELEMENTS[_id]
    end

    (1..3).each do |_i|
      _id     = find_member(CsvHdr::ITEM_ID[_i]).value
      _cannon = @item_data[_id]
      if _cannon
        if _id != -1
          case region
          when 'E'
            _name = _cannon.find_member(CsvHdr::NAME_US_STR).value
          when 'J'
            _name = _cannon.find_member(CsvHdr::NAME_JP_STR).value
          when 'P'
            _name = _cannon.find_member(CsvHdr::NAME_GB_STR).value
          end
        else
          _name = 'None'
        end
      else
        _name = '???'
      end
      find_member(CsvHdr::ITEM_NAME[_i]).value = _name
    end

    (1..3).each do |_i|
      _id   = find_member(CsvHdr::ITEM_DROP_ID[_i]).value
      find_member(CsvHdr::ITEM_DROP_NAME[_i]).value = DROPS[_id]
    end
    
    super
  end

#------------------------------------------------------------------------------
# Public member variables
#------------------------------------------------------------------------------

  attr_accessor :item_data

end	# class EnemyShip

# -- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --

end	# module ALX
