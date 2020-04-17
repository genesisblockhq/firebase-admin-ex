defmodule FirebaseAdminEx.Messaging.Message do
  @moduledoc """
  This module is responsible for representing the
  attributes of FirebaseAdminEx.Message.
  """

  alias __MODULE__
  alias FirebaseAdminEx.Messaging.WebMessage.Config, as: WebMessageConfig
  alias FirebaseAdminEx.Messaging.AndroidMessage.Config, as: AndroidMessageConfig
  alias FirebaseAdminEx.Messaging.APNSMessage.Config, as: APNSMessageConfig

  @keys [
    data: %{},
    notification: %{},
    webpush: nil,
    android: nil,
    apns: nil,
    token: nil
  ]

  @type t :: %Message{
          data: map(),
          notification: map(),
          webpush: WebMessageConfig.t() | nil,
          android: AndroidMessageConfig.t() | nil,
          apns: APNSMessageConfig.t() | nil,
          token: String.t()
        }

  @derive Jason.Encoder
  defstruct @keys

  # Public API
  def new(%{token: token, webpush: webpush} = attributes) do
    %Message{
      data: Map.get(attributes, :data, %{}),
      notification: Map.get(attributes, :notification, %{}),
      webpush: webpush,
      token: token
    }
  end

  def new(%{token: token, android: android} = attributes) do
    %Message{
      data: Map.get(attributes, :data, %{}),
      notification: Map.get(attributes, :notification, %{}),
      android: android,
      token: token
    }
  end

  def new(%{token: token, apns: apns} = attributes) do
    %Message{
      data: Map.get(attributes, :data, %{}),
      notification: Map.get(attributes, :notification, %{}),
      apns: apns,
      token: token
    }
  end

  def new(%{token: token} = attributes) do
    %Message{
      data: Map.get(attributes, :data, %{}),
      notification: Map.get(attributes, :notification, %{}),
      token: token
    }
  end

  def validate(%Message{token: nil}), do: {:error, "[Message] token is missing"}

  def validate(%Message{} = message) do
    [
      message.webpush && WebMessageConfig.validate(message.webpush),
      message.android && AndroidMessageConfig.validate(message.android),
      message.apns && APNSMessageConfig.validate(message.apns)
    ]
    |> Enum.find({:ok, message}, fn
      {:error, _} -> true
      _ -> false
    end)
  end

  def validate(_), do: {:error, "[Message] Invalid payload"}
end
