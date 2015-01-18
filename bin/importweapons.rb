#! /usr/bin/ruby
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
#                                   REQUIRES
#==============================================================================

require_relative('../lib/alx/executable.rb')
require_relative('../lib/alx/weapondata.rb')

# -- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --

module ALX

#==============================================================================
#                                    CLASS
#==============================================================================

# Class to import weapons from +FILE_INPUT+ to +FILE_OUTPUT+.
class WeaponImporter
  
#==============================================================================
#                                   INCLUDES
#==============================================================================

  include(Executable)
  
#==============================================================================
#                                  CONSTANTS
#==============================================================================

  # Path to the source file
  FILE_INPUT  = File.expand_path(
    File.join(File.dirname(__FILE__), '../share/csv/weapons.csv')
  )
  # Path to the destination file
  FILE_OUTPUT = File.expand_path(
    File.join(File.dirname(__FILE__), '../share/root/&&systemdata/Start.dol')
  )
  
#==============================================================================
#                                   PUBLIC
#==============================================================================

  public

  def initialize
    @data = WeaponData.new
  end

  def exec
    if valid?
      @data.load_from_csv(FILE_INPUT)
      @data.save_to_bin(FILE_OUTPUT)
    end
  end

  # Returns +true+ if all necessary commands and files exist, otherwise 
  # +false+.
  # 
  # @return [Boolean] +true+ if all necessary commands and files exist, 
  #                   otherwise +false+.
  def valid?
    _valid   = super
    _valid &&= has_file?(FILE_INPUT)
  end
  
end	# class WeaponImporter

# -- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --

end	# module ALX

# -- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --

if __FILE__ == $0
  begin
    _wi = ALX::WeaponImporter.new
    _wi.exec
  rescue => _e
    print(_e.class, "\n", _e.message, "\n", _e.backtrace.join("\n"), "\n")
  end
end
