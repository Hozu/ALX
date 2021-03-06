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

require('securerandom')
require_relative('executable.rb')

# -- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --

module ALX

#==============================================================================
#                                    CLASS
#==============================================================================

# Class to handle metadata for snapshots.
class MetaData

#==============================================================================
#                                   PUBLIC
#==============================================================================

  public
  
  # Constructs a MetaData.
  # @param _cache_id [String] Cache ID
  def initialize(_cache_id)
    @version  = Executable::VERSION
    @uuid     = SecureRandom.uuid
    @cache_id = _cache_id
    @created  = Time.new
    @modified = Time.new + 1
  end

  # Returns +true+ if the metadata version is valid, otherwise +false+.
  # @return [Boolean] +true+ if metadata version is valid, otherwise +false+.
  def valid?
    _result   = true
    _result &&= (@version == Executable::VERSION)
    _result &&= @cache_id.is_a?(String)
    _result
  end

  # Returns +true+ if the metadata has modified, otherwise +false+.
  # @return [Boolean] +true+ if metadata has modified, otherwise +false+.
  def updated?
    @modified > @created
  end

  # Checks the modification time of the given file and updates #modified if it 
  # is newer.
  # @param _filename [String] File name
  def check_mtime(_filename)
    _mtime = File.mtime(_filename)
    if _mtime > @modified
      @modified = _mtime
    end
  end
  
  # Provides marshalling support for use by the Marshal library.
  # @param _hash [Hash] Hash object
  def marshal_load(_hash)
    _hash.each do |_sym, _value|
      instance_variable_set(_sym, _value)
    end
    @modified = Time.new(0)
  end
  
  # Provides marshalling support for use by the Marshal library.
  # @return [Hash] Hash object
  def marshal_dump
    _hash             = {}
    _hash[:@version ] = @version
    _hash[:@uuid    ] = @uuid
    _hash[:@cache_id] = @cache_id
    _hash[:@created ] = @created
    _hash
  end

#------------------------------------------------------------------------------
# Public member variables
#------------------------------------------------------------------------------

  attr_accessor :version
  attr_accessor :uuid
  attr_accessor :cache_id
  attr_accessor :created
  attr_accessor :modified

end # class MetaData

# -- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --

end # module ALX
