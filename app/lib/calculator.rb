class Calculator
  attr_accessor :vars
  def initialize vars
    @vars = vars
    self.class.variables.each do |var, info|
      if !@vars.has_key? var
        @vars[var] = info[:default_value]
      end
    end
    @vars.each do |key, value|
      @vars[key] = value.to_f # coerce to float
    end
  end

  def multiplier
    2.5 ## fixed? cell E11
  end

  def self.variables
    {
      avg_total_monthly_payroll: {
        :description => "Avg. total monthly payroll, incl. contractors (1) (2)",
        :default_value => 85000
      },
      n_employees_making_gt_100k: {
        :description => "# of employees making >$100k annually",
        :default_value => 4
      },
      avg_annual_comp_across_gt_100k_employees: {
        :description => "Avg. annual comp across >$100k/yr employees",
        :default_value => 120000
      },
      n_contractors_making_gt_8300_mo: {
        :description => "# of contractors making >$8.3k monthly",
        :default_value => 1
      },
      avg_monthly_comp_across_gt_8300_mo_contractors: {
        :description => "Avg. monthly comp across >$8.3k/mo contractors",
        :default_value => 10000
      },
      avg_monthly_payroll_in_first_2mos_post_loan_origination: {
        :description => "Avg. monthly payroll in first 2mo's post loan origination",
        :default_value => 75000
      },
      avg_monthly_rent_or_mortgage_in_first_2mos: {
        :description => "Avg. monthly rent or mortgage in first 2mo's",
        :default_value => 4000
      },
      avg_monthly_utilities_in_first_2mos: {
        :description => "Avg. monthly utilities in first 2mo's (3)",
        :default_value => 1000
      },
      avg_of_ftes_mo_between_feb_june_of_2019: {
        :description => "Avg. # of FTEs/mo between Feb-June of 2019",
        :default_value => 10
      },
      avg_of_ftes_mo_in_first_2mos_post_loan_origination: {
        :description => "Avg. # of FTEs/mo in first 2mo's post loan origination",
        :default_value => 9
      },
      n_salary_reductions_for_ftes_making_gt_100k: {
        :description => "# of salary reductions for FTEs making <$100k",
        :default_value => 2
      },
      avg_salary_across_impacted_ftes_pre_reduction: {
        :description => "Avg. salary across impacted FTEs pre-reduction",
        :default_value => 80000
      },
      avg_salary_across_impacted_ftes_post_reduction: {
        :description => "Avg. salary across impacted FTEs post-reduction",
        :default_value => 55000
      },
    }
  end

  def maximum_loan_size
    # minimum of multiplier * eligible payroll and 10000000
    [(multiplier * payroll_eligible_for_loan_calculation), 10000000].min
  end

  def payroll_eligible_for_loan_calculation
    @vars[:avg_total_monthly_payroll] - (
      (@vars[:avg_annual_comp_across_gt_100k_employees]-100000) / 12 *
       @vars[:n_employees_making_gt_100k] + (
        (@vars[:avg_monthly_comp_across_gt_8300_mo_contractors] - 8.33 ) * @vars[:n_contractors_making_gt_8300_mo]
      )
    )
  end

  def monthly_expenses_eligible_for_forgiveness
    (
      @vars[:avg_monthly_payroll_in_first_2mos_post_loan_origination] +
      @vars[:avg_monthly_rent_or_mortgage_in_first_2mos] +
      @vars[:avg_monthly_utilities_in_first_2mos]
    )
  end

  def expenses_eligible_for_forgiveness
    monthly_expenses_eligible_for_forgiveness * 2 ## 8 weeks = monthly * 2
  end

  def amount_eligible_for_forgiveness
    if (expenses_eligible_for_forgiveness - total_reduction_in_forgiveness_amount) > maximum_loan_size
      maximum_loan_size
    else
      (expenses_eligible_for_forgiveness - total_reduction_in_forgiveness_amount)
    end
  end

  def final_loan_balance
    maximum_loan_size - amount_eligible_for_forgiveness
  end

  def n_loan_payments
    120
  end

  def monthly_loan_payments
    rate = 0.04/12
    pv = final_loan_balance
    return (pv*rate) / (1 - (1 + rate)**(-n_loan_payments)) * -1
  end

  def total_loan_payments
    monthly_loan_payments * n_loan_payments
  end

  def total_interest_paid
    final_loan_balance + total_loan_payments
  end


  def total_reduction_in_forgiveness_amount
    # binding.pry
    if (
      @vars[:avg_of_ftes_mo_in_first_2mos_post_loan_origination] < @vars[:avg_of_ftes_mo_between_feb_june_of_2019]
    )
        total = (
          (@vars[:avg_monthly_payroll_in_first_2mos_post_loan_origination] * 2) * (1 - @vars[:avg_of_ftes_mo_in_first_2mos_post_loan_origination] / @vars[:avg_of_ftes_mo_between_feb_june_of_2019])
        )
    else
      total = 0
    end
    if ((
      @vars[:avg_salary_across_impacted_ftes_post_reduction] - (@vars[:avg_salary_across_impacted_ftes_pre_reduction] * 0.75)
      ) > 0)
        total = total + 0
    else
      total = total + (
          @vars[:avg_salary_across_impacted_ftes_post_reduction] - (@vars[:avg_salary_across_impacted_ftes_pre_reduction]*0.75)
         ) * (@vars[:n_salary_reductions_for_ftes_making_gt_100k] * -1)
    end
    return total
  end
end
