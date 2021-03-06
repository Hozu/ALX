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

require_relative('charactermagicdata.rb')
require_relative('enemyshipdata.rb')
require_relative('enemyshiptask.rb')
require_relative('tecfile.rb')

# -- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --

module ALX

#==============================================================================
#                                    CLASS
#==============================================================================

# Class to handle enemy ship tasks from binary and/or CSV files.
class EnemyShipTaskData < EntryData

#==============================================================================
#                                   PUBLIC
#==============================================================================

  public

  # Constructs a EnemyShipTaskData.
  # @param _root [GameRoot] Game root
  def initialize(_root)
    super(EnemyShipTask, _root)
    @tec_file             = sys(:tec_file)
    @csv_file             = SYS.enemy_ship_task_csv_file
    @tpl_file             = SYS.enemy_ship_task_tpl_file
    @character_magic_data = CharacterMagicData.new(_root)
    @enemy_ship_data      = EnemyShipData.new(_root)
    @data                 = []
  end

  # Creates an entry.
  # @param _id [Integer] Entry ID
  # @return [Entry] Entry object
  def create_entry(_id = -1)
    _entry             = super()
    _entry.id          = _id
    _entry.magics      = @character_magic_data.data
    _entry.enemy_ships = @enemy_ship_data.data
    _entry
  end
  
  # Reads all snaphots (instance variables) from SHT files.
  def load_all_from_sht
    super
    load_data_from_sht(:data)
  end
  
  # Writes all snaphots (instance variables) to SHT files.
  def save_all_to_sht
    super
    save_data_to_sht(:data, @data)
  end

  # Reads all entries from a binary file.
  # @param _filename [String] File name
  def load_entries_from_bin(_filename)
    meta.check_mtime(_filename)
    _file             = TecFile.new(root)
    _file.magics      = @character_magic_data.data
    _file.enemy_ships = @enemy_ship_data.data
    _file.load(_filename)
    @data.concat(_file.tasks)
  end

  # Reads all entries from binary files.
  def load_all_from_bin
    @character_magic_data.load_all_from_bin
    @enemy_ship_data.load_all_from_bin
    
    glob(@tec_file) do |_p|
      if File.file?(_p)
        load_entries_from_bin(_p)
      end
    end
  end

  # Writes all entries to a binary file.
  # @param _filename [String] File name
  def save_entries_to_bin(_filename)
    unless meta.updated?
      LOG.info(sprintf(VOC.skip, _filename, VOC.open_data))
      return
    end
    
    FileUtils.mkdir_p(File.dirname(_filename))
    _file           = TecFile.new(root)
    _file.tasks     = @data
    _file.save(_filename)
  end

  # Writes all entries to binary files.
  def save_all_to_bin
    _files = []
    @data.each do |_entry|
      _filename = _entry.file
      unless _files.include?(_filename)
        _files << _filename
      end
    end
    _files.sort!

    _dirname = File.dirname(@tec_file)
    _files.each do |_filename|
      save_entries_to_bin(glob(_dirname, _filename))
    end
  end

  # Reads all data entries from a CSV file.
  # @param _filename [String]  File name
  # @param _force    [Boolean] Skip missing file
  def load_data_from_csv(_filename, _force = false)
    if _force && !File.exist?(_filename)
      return
    end
    unless @data.empty?
      return
    end

    LOG.info(sprintf(VOC.open, _filename, VOC.open_read, VOC.open_data))

    meta.check_mtime(_filename)
    CSV.open(_filename, headers: true) do |_f|
      _snapshot = snapshots[:data].dup

      while !_f.eof?
        LOG.info(sprintf(VOC.read, [0, _f.lineno - 1].max, _f.pos))
        _entry = create_entry
        _entry.read_from_csv(_f)

        if _snapshot
          _result = false
          _snapshot.reject! do |_sht|
            if _result
              break
            end
            _result = _entry.check_expiration(_sht)
          end
        else
          _entry.expired = true
        end
        
        @data << _entry
      end
    end

    LOG.info(sprintf(VOC.close, _filename))
  end

  # Reads all entries from CSV files (TPL files first, CSV files last).
  def load_all_from_csv
    load_data_from_csv(File.join(SYS.share_dir, @tpl_file), true)
    load_data_from_csv(File.join(root.dirname , @csv_file)      )
  end

  # Writes all data entries to a CSV file.
  # @param _filename [String] File name
  def save_data_to_csv(_filename)
    if @data.empty?
      return
    end
    if File.exist?(_filename) && !meta.updated?
      LOG.info(sprintf(VOC.skip, _filename, VOC.open_data))
      return
    end
    
    LOG.info(sprintf(VOC.open, _filename, VOC.open_write, VOC.open_data))

    _header = create_entry.header
    
    FileUtils.mkdir_p(File.dirname(_filename))
    CSV.open(_filename, 'w', headers: _header, write_headers: true) do |_f|
      @data.each do |_entry|
        LOG.info(sprintf(VOC.write, [0, _f.lineno - 1].max, _f.pos))
        _entry.write_to_csv(_f)
      end
    end
    
    LOG.info(sprintf(VOC.close, _filename))
  end

  # Writes all entries to CSV files.
  def save_all_to_csv
    save_data_to_csv(glob(@csv_file))
  end

#------------------------------------------------------------------------------
# Public member variables
#------------------------------------------------------------------------------

  attr_accessor :tec_file
  attr_accessor :csv_file
  attr_accessor :tpl_file
  attr_accessor :data

end # class EnemyShipTaskData

# -- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --

end # module ALX
