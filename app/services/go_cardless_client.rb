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
        }
    )
  end

  def complete_redirect_flow(flow_id:, user:)
    redirect_flow = client.redirect_flows.complete(flow_id, params: {session_token: user.email})
    puts "Mandate: #{redirect_flow.links.mandate}"
    puts "Customer: #{redirect_flow.links.customer}"
    puts "Confirmation URL: #{redirect_flow.confirmation_url}" # send back to client
    # TODO: save the customer's mandate in database
    redirect_flow
  end

  def create_subscription(amount_in_cents:, currency:, interval_unit:, day_of_month:, user:)
    subscription = client.subscriptions.create(
        params: {
            amount: amount_in_cents,
            currency: currency.presence || 'USD',
            interval_unit: interval_unit.presence || 'monthly',
            day_of_month: day_of_month.presence || '5',
            links: {
                mandate: 'user.mandate_id' # TODO: fetch mandate id from database
            },
            metadata: {
                subscription_number: 'user.subscription_id' # TODO: create subscription in db first and pass uuid
            }
        },
        headers: {
            'Idempotency-Key' => 'user.subscription_id' # TODO: send a unique id
        }
    )
    puts subscription.id #save this and subscription data to subscriptions table
    subscription
  end

  def get_subscription(cardless_sub_id:)
    client.subscriptions.get(cardless_sub_id)
  end

  def cancel_subscription(cardless_sub_id:)
    client.subscriptions.cancel(cardless_sub_id)
  end

  private

  def setup_go_cardless
    GoCardlessPro::Client.new(
        access_token: ENV['GC_ACCESS_TOKEN'],
        environment: :sandbox
    )
  end
end