# coding: utf-8
class UserGroup < ActiveRecord::Base
  attr_accessible :user_id, :group_id, :state, :role

  belongs_to :user
  belongs_to :group
  validates_uniqueness_of :user_id, :scope => [:group_id]
  validates :role, :length => { :maximum => 16 }
end
