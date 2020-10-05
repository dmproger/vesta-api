require 'gocardless_pro'

class GoCardlessClient
  attr_reader :client

  def initialize
    @client = setup_go_cardless
  end

  def get_customers
    client.customers.list.records
  end

  def create_redirect_flow(user:, redirect_url:)
    client.redirect_flows.create(
        params: {
            description: 'Vesta Subscription',
            session_token: user.email,
            success_redirect_url: "#{redirect_url}?session=#{user.email}",
            prefilled_customer: {
                given_name: user.first_name,
                family_name: user.surname,
                email: user.email,
                address_line1: user.address_1,
                city: user.city,
                postal_code: user.post_code
            }
        },
        headers: {
            'Idempotency-Key' => user.email
        }
    )
  end

  def complete_redirect_flow(flow_id:, user:)
    client.redirect_flows.complete(flow_id, params: {session_token: user.email})
  end

  def create_subscription(subscription:)
    client.subscriptions.create(
        params: {
            amount: subscription.amount.to_i,
            currency: subscription.currency.presence || 'GBP',
            interval_unit: subscription.interval_unit,
            day_of_month: subscription.day_of_month.presence || default_day_of_month,
            start_date: start_date(subscription),
            month: subscription.yearly? ? month_name(subscription) : nil,
            links: {
                mandate: subscription.mandate
            },
            metadata: {
                subscription_number: subscription.id
            }
        },
        headers: {
            'Idempotency-Key' => subscription.id
        }
    )
  rescue StandardError => e
    puts e.as_json
  end

  def get_subscription(external_sub_id:)
    client.subscriptions.get(external_sub_id)
  end

  def cancel_subscription(external_sub_id:)
    client.subscriptions.cancel(external_sub_id)
  end

  private

  def month_name(subscription)
    subscription.month.presence || Date::MONTHNAMES[Date.current.month].downcase
  end

  def default_day_of_month
    Date.current.day < 28 ? Date.current.day : -1
  end

  def start_date(subscription)
    if subscription.day_of_month.present?
      subscription.day_of_month.present? ? nil : subscription.start_date
    else
      subscription.monthly? ? Date.current : 2.months.from_now.to_date
    end
  end

  def setup_go_cardless
    GoCardlessPro::Client.new(
        access_token: ENV['GC_ACCESS_TOKEN'],
        environment: :sandbox
    )
  end
end