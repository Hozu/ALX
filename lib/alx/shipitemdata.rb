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

require_relative('entrytransform.rb')
require_relative('shipitem.rb')
require_relative('stdentrydata.rb')

# -- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --

module ALX

#==============================================================================
#                                    CLASS
#==============================================================================

# Class to handle ship items from binary and/or CSV files.
class ShipItemData < StdEntryData
  
#==============================================================================
#                                  CONSTANTS
#==============================================================================

  # Range of entry IDs
  ID_RANGE    = 0x1e0...0x1fe

  # Offset ranges of data entries
  DATA_FILES = {
    'E' => DataRange.new(DOL_FILE, 0x2d5a2c...0x2d5e64),
    'J' => DataRange.new(DOL_FILE, 0x2d566c...0x2d5aa4),
    'P' => DataRange.new(DOL_FILE, 0x2f877c...0x2f8a4c),
  }

  # Offset ranges of name entries
  NAME_FILES = {
    'P' => [
      DataRange.new(SOT_FILE_DE, 0x1ec15...0x1ed75),
      DataRange.new(SOT_FILE_ES, 0x1e9cd...0x1eb78),
      DataRange.new(SOT_FILE_FR, 0x1ec03...0x1ed91),
      DataRange.new(SOT_FILE_GB, 0x1e27d...0x1e3dd),
    ],
  }

  # Offset ranges of description entries
  DSCR_FILES = {
    'E' => DataRange.new(DOL_FILE, 0x2cfbf0...0x2d05c4),
    'J' => DataRange.new(DOL_FILE, 0x2cfc58...0x2d058c),
    'P' => [
      DataRange.new(SOT_FILE_DE, 0x1abb8...0x1b603),
      DataRange.new(SOT_FILE_ES, 0x1a7f2...0x1b23a),
      DataRange.new(SOT_FILE_FR, 0x1a998...0x1b3e9),
      DataRange.new(SOT_FILE_GB, 0x1a38c...0x1ad4b),
    ],
  }

  # Path to CSV file
  CSV_FILE = 'csv/shipitems.csv'

#==============================================================================
#                                   PUBLIC
#==============================================================================

  public

  # Constructs a ShipItemData.
  # @param _root [GameRoot] Game root
  def initialize(_root)
    super(ShipItem, _root)
    self.id_range   = ID_RANGE
    self.data_files = DATA_FILES
    self.name_files = NAME_FILES
    self.dscr_files = DSCR_FILES
    self.csv_file   = CSV_FILE
  end

end # class ShipItemData

# -- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --

end # module ALX
