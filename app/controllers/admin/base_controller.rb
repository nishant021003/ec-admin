# frozen_string_literal: true

module Admin
  class BaseController < ApplicationController
    include CartSupport
    before_action :authenticate_admin!
  end
end
