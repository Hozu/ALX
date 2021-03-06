#! /usr/bin/ruby
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

require('pathname')
require_relative('../../lib/alx/entrytransform.rb')

# -- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --

module ALX

#==============================================================================
#                                    CLASS
#==============================================================================
  
# Class to create backups in the "share" directory.
class BackupCreator < EntryTransform

#==============================================================================
#                                   PUBLIC
#==============================================================================

  public

  # Constructs an BackupCreator.
  def initialize
    super(GameRoot)
  end
  
  # Creates an entry data object.
  # @param _root [GameRoot] Game root
  # @return [EntryData] Entry data object
  def create_entry_data(_root)
    _root
  end
  
  def exec
    super
    
    data.each do |_root|
      Dir.chdir(_root.dirname) do
        Dir.glob(_root.sys(:exec_file)).each do |_p|
          create_backup(_root, _p)
        end
        
        create_backup(_root, _root.sys(:evp_file))
        create_backup(_root, _root.sys(:level_file))

        Dir.glob(_root.sys(:enp_file)).each do |_p|
          create_backup(_root, _p)
        end
        Dir.glob(_root.sys(:eb_file)).each do |_p|
          create_backup(_root, _p)
        end
        Dir.glob(_root.sys(:ec_file)).each do |_p|
          create_backup(_root, _p)
        end
        Dir.glob(_root.sys(:tec_file)).each do |_p|
          create_backup(_root, _p)
        end
        
        Dir.glob(_root.sys(:sot_file_de)).each do |_p|
          create_backup(_root, _p)
        end
        Dir.glob(_root.sys(:sot_file_es)).each do |_p|
          create_backup(_root, _p)
        end
        Dir.glob(_root.sys(:sot_file_fr)).each do |_p|
          create_backup(_root, _p)
        end
        Dir.glob(_root.sys(:sot_file_gb)).each do |_p|
          create_backup(_root, _p)
        end
      end
    end
  end

  # Creates a backup.
  # @param _root     [GameRoot] Game root
  # @param _filename [String]   Backup to create
  def create_backup(_root, _filename)
    _src_file = File.expand_path(_filename, _root.dirname)
    _base_dir = Pathname.new(File.expand_path(SYS.root_dir, _root.dirname))
    _root_dir = Pathname.new(_src_file)
    _dst_file = File.expand_path(
      _root_dir.relative_path_from(_base_dir),
      File.join(_root.dirname, SYS.archive_dir)
    )

    begin
      FileUtils.mkdir_p(File.dirname(_dst_file))
      FileUtils.cp(_src_file, _dst_file)
      _result = File.exist?(_dst_file)
    rescue StandardError
      _result = false
    end

    _msg = sprintf('Create backup: %s', _dst_file)
    if _result
      _msg += sprintf(' - %s', VOC.done)
      ALX::LOG.info(_msg)
    else
      _msg += sprintf(' - %s', VOC.failed)
      ALX::LOG.error(_msg)
    end
  end

end # class BackupCreator

# -- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --

end # module ALX

# -- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --

if __FILE__ == $0
  ALX::Main.call do
    _br = ALX::BackupCreator.new
    _br.exec
  end
end
