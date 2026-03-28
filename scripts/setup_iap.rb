#!/usr/bin/env ruby
# Setup IAP localization and pricing

require 'jwt'
require 'net/http'
require 'json'
require 'openssl'

KEY_ID = "49PVFZRL27"
ISSUER_ID = "5210488e-2060-4ef4-9cf7-d0b7975a92e0"
KEY_PATH = File.expand_path("~/.appstoreconnect/private_keys/AuthKey_#{KEY_ID}.p8")

IAP_ID = "6761312404"

# Generate JWT token
private_key = OpenSSL::PKey::EC.new(File.read(KEY_PATH))

payload = {
  iss: ISSUER_ID,
  iat: Time.now.to_i,
  exp: Time.now.to_i + 20 * 60,
  aud: "appstoreconnect-v1"
}

token = JWT.encode(payload, private_key, 'ES256', { kid: KEY_ID, typ: 'JWT' })

def make_request(method, path, token, body = nil, version = 1)
  uri = URI("https://api.appstoreconnect.apple.com/v#{version}/#{path}")
  http = Net::HTTP.new(uri.host, uri.port)
  http.use_ssl = true

  case method
  when :get
    request = Net::HTTP::Get.new(uri)
  when :post
    request = Net::HTTP::Post.new(uri)
    request.body = body.to_json if body
  end

  request['Authorization'] = "Bearer #{token}"
  request['Content-Type'] = 'application/json'

  response = http.request(request)
  parsed = begin
    JSON.parse(response.body)
  rescue
    response.body
  end
  [response.code.to_i, parsed]
end

# Create localization with shorter description
puts "Creating localization..."

loc_body = {
  data: {
    type: "inAppPurchaseLocalizations",
    attributes: {
      name: "Unlock SlapPhone",
      description: "All features & voice packs. One-time buy.",  # Max 55 chars
      locale: "en-US"
    },
    relationships: {
      inAppPurchaseV2: {
        data: {
          type: "inAppPurchases",
          id: IAP_ID
        }
      }
    }
  }
}

status, result = make_request(:post, "inAppPurchaseLocalizations", token, loc_body, 1)

if status == 201
  puts "Localization created!"
else
  puts "Localization: #{status} - #{result}"
end

# Get price points to find $4.99 tier
puts "\nFetching price points..."
status, result = make_request(:get, "inAppPurchasePricePoints?filter[territory]=USA&limit=50", token, nil, 1)

if status == 200
  price_points = result["data"] || []
  # Find $4.99 price point
  target_point = price_points.find { |pp| pp.dig("attributes", "customerPrice") == "4.99" }

  if target_point
    puts "Found $4.99 price point: #{target_point['id']}"

    # Create price schedule
    puts "Setting price..."

    price_body = {
      data: {
        type: "inAppPurchasePriceSchedules",
        relationships: {
          inAppPurchase: {
            data: {
              type: "inAppPurchases",
              id: IAP_ID
            }
          },
          manualPrices: {
            data: [
              {
                type: "inAppPurchasePrices",
                id: "${new}"
              }
            ]
          },
          baseTerritory: {
            data: {
              type: "territories",
              id: "USA"
            }
          }
        }
      },
      included: [
        {
          type: "inAppPurchasePrices",
          id: "${new}",
          attributes: {
            startDate: nil
          },
          relationships: {
            inAppPurchasePricePoint: {
              data: {
                type: "inAppPurchasePricePoints",
                id: target_point['id']
              }
            },
            inAppPurchaseV2: {
              data: {
                type: "inAppPurchases",
                id: IAP_ID
              }
            }
          }
        }
      ]
    }

    status2, result2 = make_request(:post, "inAppPurchasePriceSchedules", token, price_body, 1)

    if status2 == 201
      puts "Price set to $4.99!"
    else
      puts "Price error: #{status2} - #{result2}"
    end
  else
    puts "Could not find $4.99 price point"
    puts "Available prices: #{price_points.map { |pp| pp.dig('attributes', 'customerPrice') }.compact.uniq.sort.join(', ')}"
  end
else
  puts "Error fetching price points: #{status} - #{result}"
end

puts "\nDone!"
