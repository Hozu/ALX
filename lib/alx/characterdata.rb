#******************************************************************************
# ALX - Skies of Arcadia Legends Examiner
# Copyright (C) 2019 Marcel Renner
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

require_relative('armordata.rb')
require_relative('accessorydata.rb')
require_relative('character.rb')
require_relative('weapondata.rb')

# -- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --

module ALX

#==============================================================================
#                                    CLASS
#==============================================================================

# Class to handle characters from binary and/or CSV files.
class CharacterData < StdEntryData

#==============================================================================
#                                   PUBLIC
#==============================================================================

  public

  # Constructs a CharacterData.
  # @param _root [GameRoot] Game root
  def initialize(_root)
    super(Character, _root)
    self.id_range   = sys(:character_id_range)
    self.data_file  = sys(:character_data_files)
    self.csv_file   = SYS.character_csv_file
    self.tpl_file   = SYS.character_tpl_file
    @weapon_data    = WeaponData.new(_root)
    @armor_data     = ArmorData.new(_root)
    @accessory_data = AccessoryData.new(_root)
  end

  # Creates an entry.
  # @param _id [Integer] Entry ID
  # @return [Entry] Entry object
  def create_entry(_id = -1)
    _entry             = super
    _entry.weapons     = @weapon_data.data
    _entry.armors      = @armor_data.data
    _entry.accessories = @accessory_data.data
    _entry
  end
  
  # Reads all entries from binary files.
  def load_all_from_bin
    @weapon_data.load_all_from_bin
    @armor_data.load_all_from_bin
    @accessory_data.load_all_from_bin
    super
  end

end # class CharacterData

# -- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --

end # module ALX
