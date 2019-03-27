//
//  ScrollView.swift
//  Tokamak
//
//  Created by Matvii Hodovaniuk on 2/28/19.
//

public struct ScrollView: HostComponent {
  public struct Props: Equatable, StyleProps, Default {
    public static var defaultValue: Props {
      return Props()
    }

    public let style: Style?
    public let scrollOptions: ScrollOptions?

    public init(
      _ style: Style? = nil,
      scrollOptions: ScrollOptions? = nil
    ) {
      self.style = style
      self.scrollOptions = scrollOptions
    }
  }

  public typealias Children = AnyNode
}
