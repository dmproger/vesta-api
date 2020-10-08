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

  def create_subscription(subscription:, user:)
    client.subscriptions.create(
        params: {
            amount: subscription.amount.to_i,
            currency: subscription.currency.presence || 'GBP',
            interval_unit: subscription.interval_unit,
            day_of_month: subscription.yearly? ? (subscription.day_of_month.presence || Date.current) : nil,
            start_date: start_date(subscription),
            month: subscription.yearly? ? month_name(subscription) : nil,
            links: {
                mandate: user.mandate
            },
            metadata: {
                subscription_number: subscription.id
            }
        },
        headers: {
            'Idempotency-Key' => subscription.id
        }
    )
  end

  def get_subscription(external_sub_id:)
    client.subscriptions.get(external_sub_id) rescue nil
  end

  def get_mandate(mandate_id:)
    client.mandates.get(mandate_id) rescue nil
  end

  def cancel_subscription(external_sub_id:)
    client.subscriptions.cancel(external_sub_id)
  end

  def get_payment(payment_id:)
    client.payments.get(payment_id) rescue nil
  end

  private

  def month_name(subscription)
    subscription.month.presence || Date::MONTHNAMES[Date.current.month].downcase
  end

  def start_date(subscription)
    2.months.from_now.to_date if subscription.yearly?
  end

  def setup_go_cardless
    GoCardlessPro::Client.new(
        access_token: ENV['GC_ACCESS_TOKEN'],
        environment: :sandbox
    )
  end
end