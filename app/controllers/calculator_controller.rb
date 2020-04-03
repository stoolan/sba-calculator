class CalculatorController < ApplicationController
  def index
    @calc = Calculator.new(calculator_params)
  end

  private
  def calculator_params
    params.permit(Calculator.variables.keys)
  end
end
