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

require_relative('binaryfile.rb')

# -- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --

module ALX

#==============================================================================
#                                    CLASS
#==============================================================================

# Class to handle a IP.BIN file.
class IPFile

#==============================================================================
#                                   PUBLIC
#==============================================================================

  public

  # Constructs a IPFile.
  def initialize
    @product_id      = ''
    @product_name    = ''
    @product_version = ''
    @product_date    = ''
    @region_id       = ''
    @maker_id        = ''
    @maker_name      = ''
    @description     = ''
  end

  # Reads a IP.BIN file.
  # @param _filename [String] File name
  def load(_filename)
    BinaryFile.open(_filename, 'rb', little_endian: true) do |_f|
      _f.pos           = 0x10
      @maker_id        = _f.read_str(0x10)
      
      _f.pos           = 0x24
      @description     = _f.read_str(0xc).strip
      
      _f.pos           = 0x30
      @region_id       = _f.read_str(0x8).strip

      _f.pos           = 0x40
      @product_id      = _f.read_str(0xa)
      @product_version = _f.read_str(0x6)
      @product_date    = _f.read_str(0x10)
      
      _f.pos           = 0x70
      @maker_name      = _f.read_str(0x10)
      @product_name    = _f.read_str(0x80)
    end
  end

#------------------------------------------------------------------------------
# Public member variables
#------------------------------------------------------------------------------

  attr_reader :product_id
  attr_reader :product_name
  attr_reader :product_version
  attr_reader :product_date
  attr_reader :region_id
  attr_reader :maker_id
  attr_reader :maker_name
  attr_reader :description

end	# class IPFile

# -- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --

end	# module ALX
