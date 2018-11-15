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

require('fileutils')
require_relative('binaryfile.rb')
require_relative('entrydata.rb')
require_relative('message.rb')

# -- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --

module ALX

#==============================================================================
#                                    CLASS
#==============================================================================

# Base class to handle standard entries from binary and/or CSV files.
class StdEntryData < EntryData
  
#==============================================================================
#                                   PUBLIC
#==============================================================================

  public

  # Constructs a StdEntryData.
  # @param _class [Entry]    Entry object
  # @param _root  [GameRoot] Game root
  def initialize(_class, _root)
    super
    @id_range   = 0x0...0x0
    @data_files = {}
    @name_files = {}
    @dscr_files = {}
    @msg_table  = {}
    @csv_file   = ''
    @tpl_file   = ''
    
    @data = Cache[cache_id] || Hash.new do |_h, _k|
      _h[_k] = create_entry(_k)
    end
    Cache[cache_id] ||= @data
  end

  # Creates an entry.
  # @param _id [Integer] Entry ID
  # @return [Entry] Entry object
  def create_entry(_id = -1)
    _entry    = super()
    _entry.id = _id
    _entry
  end

  # Reads all data entries from a binary file.
  # @param _filename [String] File name
  def load_data_from_bin(_filename)
    print("\n")
    puts(sprintf(VOC.open, _filename, VOC.open_read, VOC.open_data))

    BinaryFile.open(_filename, 'rb') do |_f|
      _range = determine_range(@data_files[region], _filename)
      _size  = create_entry.size
      _f.pos = _range.begin
      
      @id_range.each do |_id|
        if _range.exclusions.include?(_id)
          next
        end
        if _f.eof? || _f.pos < _range.begin || _f.pos + _size > _range.end
          break
        end
        
        puts(sprintf(VOC.read, _id - @id_range.begin, _f.pos))
        _entry = @data[_id]
        _entry.read_from_bin(_f)
      end
    end
    
    puts(sprintf(VOC.close, _filename))
  end
    
  # Reads all name entries from a binary file.
  # @param _filename [String] File name
  def load_names_from_bin(_filename)
    print("\n")
    puts(sprintf(VOC.open, _filename, VOC.open_read, VOC.open_name))

    BinaryFile.open(_filename, 'rb') do |_f|
      _range = determine_range(@name_files[region], _filename)
      _f.pos = _range.begin
      
      @id_range.each do |_id|
        if _range.exclusions.include?(_id)
          next
        end
        
        _entry  = @data[_id]
        _msg_id = _entry.msg_id
    
        case region
        when 'E', 'J'
          _pos  = _entry.find_member(VOC.name_pos[country] )
          _size = _entry.find_member(VOC.name_size[country])
          _str  = _entry.find_member(VOC.name_str[country] )
        when 'P'
          _lang = determine_lang(_filename)
          _pos  = _entry.find_member(VOC.name_pos[_lang] )
          _size = _entry.find_member(VOC.name_size[_lang])
          _str  = _entry.find_member(VOC.name_str[_lang] )
        end
    
        if _range.use_msg_table
          _msg = @msg_table[_msg_id]
          if _msg
            _pos.value  = _msg.pos
            _size.value = _msg.size
            _str.value  = _msg.value
            next
          end
        end

        if _f.eof? || _f.pos < _range.begin || _f.pos >= _range.end
          next
        end
        
        puts(sprintf(VOC.read, _id - @id_range.begin, _f.pos))
        _pos.value  = _f.pos
        _str.value  = _f.read_str(0xff, 0x1, 'ISO8859-1')
        _size.value = _f.pos - _pos.value

        if _range.use_msg_table
          _msg                = Message.new
          _msg.pos            = _pos.value
          _msg.size           = _size.value
          _msg.value          = _str.value
          @msg_table[_msg_id] = _msg
        end
      end
    end

    puts(sprintf(VOC.close, _filename))
  end
  
  # Reads all description entries from a binary file.
  # @param _filename [String] File name
  def load_dscr_from_bin(_filename)
    print("\n")
    puts(sprintf(VOC.open, _filename, VOC.open_read, VOC.open_dscr))

    BinaryFile.open(_filename, 'rb') do |_f|
      _range = determine_range(@dscr_files[region], _filename)
      _f.pos = _range.begin
      
      @id_range.each do |_id|
        if _range.exclusions.include?(_id)
          next
        end
        
        _entry  = @data[_id]
        _msg_id = _entry.msg_id

        case region
        when 'E', 'J'
          _pos  = _entry.find_member(VOC.dscr_pos[country] )
          _size = _entry.find_member(VOC.dscr_size[country])
          _str  = _entry.find_member(VOC.dscr_str[country] )
        when 'P'
          _lang = determine_lang(_filename)
          _pos  = _entry.find_member(VOC.dscr_pos[_lang] )
          _size = _entry.find_member(VOC.dscr_size[_lang])
          _str  = _entry.find_member(VOC.dscr_str[_lang] )
        end
        
        if _range.use_msg_table
          _msg = @msg_table[_msg_id]
          if _msg
            _pos.value  = _msg.pos
            _size.value = _msg.size
            _str.value  = _msg.value
            next
          end
        end

        if _f.eof? || _f.pos < _range.begin || _f.pos >= _range.end
          next
        end
        
        puts(sprintf(VOC.read, _id - @id_range.begin, _f.pos))
        _pos.value  = _f.pos
        if region != 'P'
          _str.value  = _f.read_str(0xff, 0x4)
        else
          _str.value  = _f.read_str(0xff, 0x1, 'ISO8859-1')
        end
        _size.value = _f.pos - _pos.value

        if _range.use_msg_table
          _msg                = Message.new
          _msg.pos            = _pos.value
          _msg.size           = _size.value
          _msg.value          = _str.value
          @msg_table[_msg_id] = _msg
        end
      end
    end

    puts(sprintf(VOC.close, _filename))
  end

  # Reads all entries from binary files.
  def load_all_from_bin
    if !@data.empty?
      return
    end

    _ranges = @data_files[region]
    if _ranges
      unless _ranges.is_a?(Array)
        _ranges = [_ranges]
      end
      _ranges.each do |_range|
        load_data_from_bin(File.join(root.path, _range.name))
      end
    end
  
    _ranges = @name_files[region]
    if _ranges
      unless _ranges.is_a?(Array)
        _ranges = [_ranges]
      end
      _ranges.each do |_range|
        load_names_from_bin(File.join(root.path, _range.name))
      end
    end
  
    _ranges = @dscr_files[region]
    if _ranges
      unless _ranges.is_a?(Array)
        _ranges = [_ranges]
      end
      _ranges.each do |_range|
        load_dscr_from_bin(File.join(root.path, _range.name))
      end
    end
  end
    
  # Writes all data entries to a binary file.
  # @param _filename [String] File name
  def save_data_to_bin(_filename)
    if @data.empty?
      return
    end
    
    print("\n")
    puts(sprintf(VOC.open, _filename, VOC.open_write, VOC.open_data))

    FileUtils.mkdir_p(File.dirname(_filename))
    BinaryFile.open(_filename, 'r+b') do |_f|
      _range = determine_range(@data_files[region], _filename)
      _size  = create_entry.size
      
      @data.each do |_id, _entry|
        if _id < @id_range.begin && _id >= @id_range.end
          next
        end
        if _range.exclusions.include?(_id)
          next
        end
        
        _f.pos = _range.begin + (_id - @id_range.begin) * _size
        if _f.eof? || _f.pos < _range.begin || _f.pos + _size > _range.end
          next
        end
        
        puts(sprintf(VOC.write, _id - @id_range.begin, _f.pos))
        _entry.write_to_bin(_f)
      end
    end

    puts(sprintf(VOC.close, _filename))
  end
    
  # Writes all name entries to a binary file.
  # @param _filename [String] File name
  def save_names_to_bin(_filename)
    if @data.empty?
      return
    end
    
    print("\n")
    puts(sprintf(VOC.open, _filename, VOC.open_write, VOC.open_name))

    FileUtils.mkdir_p(File.dirname(_filename))
    BinaryFile.open(_filename, 'r+b') do |_f|
      _range = determine_range(@name_files[region], _filename)
      
      @data.each do |_id, _entry|
        if _id < @id_range.begin && _id >= @id_range.end
          next
        end
        if _range.exclusions.include?(_id)
          next
        end
        
        _lang = determine_lang(_filename)
        if _lang
          _pos  = _entry.find_member(VOC.name_pos[_lang] ).value
          _size = _entry.find_member(VOC.name_size[_lang]).value
          _str  = _entry.find_member(VOC.name_str[_lang] ).value
        else
          _pos  = 0
          _size = 0
        end
        if _pos <= 0 || _size <= 0
          next
        end
        
        _f.pos = _pos
        if _f.eof? || _f.pos < _range.begin || _f.pos + _size > _range.end
          next
        end
        
        puts(sprintf(VOC.write, _id - @id_range.begin, _pos))
        _f.write_str(_str, _size, 0x1, 'ISO8859-1')
      end
    end

    puts(sprintf(VOC.close, _filename))
  end
  
  # Writes all description entries to a binary file.
  # @param _filename [String] File name
  def save_dscr_to_bin(_filename)
    if @data.empty?
      return
    end
    
    print("\n")
    puts(sprintf(VOC.open, _filename, VOC.open_write, VOC.open_dscr))

    FileUtils.mkdir_p(File.dirname(_filename))
    BinaryFile.open(_filename, 'r+b') do |_f|
      _range = determine_range(@dscr_files[region], _filename) 

      @data.each do |_id, _entry|
        if _id < @id_range.begin && _id >= @id_range.end
          next
        end
        if _range.exclusions.include?(_id)
          next
        end

        case region
        when 'E', 'J'
          _pos  = _entry.find_member(VOC.dscr_pos[country] ).value
          _size = _entry.find_member(VOC.dscr_size[country]).value
          _str  = _entry.find_member(VOC.dscr_str[country] ).value
        when 'P'
          _lang = determine_lang(_filename)
          if _lang
            _pos  = _entry.find_member(VOC.dscr_pos[_lang] ).value
            _size = _entry.find_member(VOC.dscr_size[_lang]).value
            _str  = _entry.find_member(VOC.dscr_str[_lang] ).value
          else
            _pos  = 0
            _size = 0
          end
        end
        if _pos <= 0 || _size <= 0
          next
        end
        
        _f.pos = _pos
        if _f.eof? || _f.pos < _range.begin || _f.pos + _size > _range.end
          next
        end
        
        puts(sprintf(VOC.write, _id - @id_range.begin, _pos))
        if region != 'P'
          _f.write_str(_str, _size, 0x4)
        else
          _f.write_str(_str, _size, 0x1, 'ISO8859-1')
        end
      end
    end

    puts(sprintf(VOC.close, _filename))
  end
    
  # Writes all entries to binary files.
  def save_all_to_bin
    _ranges = @data_files[region]
    if _ranges
      unless _ranges.is_a?(Array)
        _ranges = [_ranges]
      end
      _ranges.each do |_range|
        save_data_to_bin(File.join(root.path, _range.name))
      end
    end
  
    _ranges = @name_files[region]
    if _ranges
      unless _ranges.is_a?(Array)
        _ranges = [_ranges]
      end
      _ranges.each do |_range|
        save_names_to_bin(File.join(root.path, _range.name))
      end
    end
  
    _ranges = @dscr_files[region]
    if _ranges
      unless _ranges.is_a?(Array)
        _ranges = [_ranges]
      end
      _ranges.each do |_range|
        save_dscr_to_bin(File.join(root.path, _range.name))
      end
    end
  end

  # Reads all data entries from a a CSV file.
  # @param _filename [String]  File name
  # @param _force    [Boolean] Skips missing file and ignore missing data members.
  def load_entries_from_csv(_filename, _force = false)
    if _force && !File.exist?(_filename)
      return
    end
  
    print("\n")
    puts(sprintf(VOC.open, _filename, VOC.open_read, VOC.open_data))

    CSV.open(_filename, headers: true) do |_f|
      while !_f.eof?
        puts(sprintf(VOC.read, [0, _f.lineno - 1].max, _f.pos))
        _row   = _f.shift
        _entry = create_entry
        _entry.read_from_csv(_row, _force)
        _exist = @data.include?(_entry.id) 

        if _force && _exist
          @data[_entry.id].read_from_csv(_row, _force)
        else
          @data[_entry.id] = _entry
        end
      end
    end

    puts(sprintf(VOC.close, _filename))
  end

  # Reads all entries from CSV files (CSV files first, TPL files last).
  def load_all_from_csv
    load_entries_from_csv(File.join(root.path    , @csv_file)      )
    load_entries_from_csv(File.join(SYS.share_dir, @tpl_file), true)
  end

  # Writes all data entries to a CSV file.
  # @param _filename [String] File name
  def save_entries_to_csv(_filename)
    if @data.empty?
      return
    end
    
    print("\n")
    puts(sprintf(VOC.open, _filename, VOC.open_write, VOC.open_data))

    _header = create_entry.header
    
    FileUtils.mkdir_p(File.dirname(_filename))
    CSV.open(_filename, 'w', headers: _header, write_headers: true) do |_f|
      @data.each do |_id, _entry|
        puts(sprintf(VOC.write, [0, _f.lineno - 1].max, _f.pos))
        _entry.write_to_csv(_f)
      end
    end
    
    puts(sprintf(VOC.close, _filename))
  end

  # Writes all entries to CSV files.
  def save_all_to_csv
    save_entries_to_csv(File.join(root.path, @csv_file))
  end

#------------------------------------------------------------------------------
# Public member variables
#------------------------------------------------------------------------------

  attr_accessor :id_range
  attr_accessor :data_files
  attr_accessor :name_files
  attr_accessor :dscr_files
  attr_accessor :msg_table
  attr_accessor :csv_file
  attr_accessor :tpl_file
  attr_accessor :data

#==============================================================================
#                                   PRIVATE
#==============================================================================

  private

  # Determines the PAL-E language for the given filename.
  # @param _filename [String] Filename
  # @return [String] PAL-E language
  def determine_lang(_filename)
    return 'DE' if _filename.include?(SYS.sot_file_de)
    return 'ES' if _filename.include?(SYS.sot_file_es)
    return 'FR' if _filename.include?(SYS.sot_file_fr)
    return 'GB' if _filename.include?(SYS.sot_file_gb)
    return ''
  end
  
end # class StdEntryData

# -- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --

end # module ALX
