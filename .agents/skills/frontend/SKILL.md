# Flutter UI Design & Development Skill

## Overview
This skill is used for all UI/UX design and development tasks related to the pet owner mobile application built in Flutter. It ensures production-grade, user-centric design that avoids generic AI-generated aesthetics.

## Trigger Keywords
Use this skill when:
- Designing or redesigning any screen/page in the Flutter app
- Creating UI mockups or wireframes for the pet owner application
- Developing flutter widgets and components
- Improving user experience or interface aesthetics
- Designing dashboard layouts, cards, navigation elements
- Creating animations or transitions
- Refining visual hierarchy and typography
- Building responsive layouts for mobile devices
- Designing for pet owner user persona

## Core Principles

### 1. Production-Grade Design Standards
- Design must be market-ready and professional
- No generic, template-like, or "AI slop" aesthetics
- Industry-standard design patterns and best practices
- Attention to detail in spacing, typography, and color harmony
- Polished, refined visual appearance

### 2. User-Centric Approach
- Design for the pet owner user persona
- Intuitive navigation and information hierarchy
- Clear call-to-action buttons and interactive elements
- Minimize cognitive load for users
- Encourage engagement and app usage

### 3. Mobile-First Design
- Optimize for mobile/smartphone first
- Responsive layouts that adapt to different screen sizes
- Touch-friendly interface elements
- Consider thumb-reachable zones on mobile
- Efficient use of screen space

### 4. Visual Consistency
- Maintain consistent color palette throughout the app
- Use unified typography system
- Consistent spacing and padding (use design system/grid)
- Unified component library across screens
- Brand-aligned design language

## Design Checklist

### Layout & Structure
- [ ] Clear information hierarchy
- [ ] Proper use of whitespace and padding
- [ ] Logical content grouping
- [ ] Responsive grid system
- [ ] Mobile-optimized layout

### Typography
- [ ] Limited font families (2-3 maximum)
- [ ] Proper font sizing hierarchy (headings, body, captions)
- [ ] Readable line heights and letter spacing
- [ ] Color contrast meets accessibility standards (WCAG AA minimum)

### Color & Visual Design
- [ ] Cohesive color palette (primary, secondary, accent colors)
- [ ] Sufficient contrast for readability
- [ ] Intentional use of color psychology
- [ ] Consistent use of shadows and elevation
- [ ] Smooth gradients (if used)

### Components & Elements
- [ ] Consistent button styles and states (normal, hover, pressed, disabled)
- [ ] Card-based layouts for content grouping
- [ ] Clear form inputs with proper labeling
- [ ] Loading states and empty states designed
- [ ] Error states clearly indicated
- [ ] Micro-interactions and feedback for user actions

### Navigation & UX
- [ ] Clear navigation structure
- [ ] Intuitive back navigation
- [ ] Tab bar or menu properly organized
- [ ] Search/filter functionality (if applicable)
- [ ] Quick action buttons placed strategically

### Specific Requirements for Pet Owner App

#### Home Screen (Post-Login)
- Dashboard-style layout (not button-based)
- Messages/messaging feature prominent
- Pet management overview visible
- Quick action cards for key features
- Notifications/alerts section
- Remove: categories, featured pets, search bar
- Design should attract and engage users

#### General Guidelines
- Avoid placeholder "AI" designs
- Use real-world design inspiration
- Implement proper spacing and grid system
- Include subtle animations for delight factor
- Ensure accessibility (color blind friendly, readable fonts)
- Test on various device sizes

## Flutter-Specific Considerations

### Widget Selection
- Use Material Design 3 components (or Cupertino for iOS-specific)
- Proper use of Scaffold, AppBar, and navigation
- Stateless vs Stateful widgets appropriately
- Custom widgets for unique design elements
- Performance-optimized widget trees

### Responsive Design
- MediaQuery for responsive layouts
- LayoutBuilder for adaptive designs
- Flexible and Expanded widgets appropriately
- SafeArea for notch/safe zone handling
- Aspect ratio considerations

### Animations & Transitions
- Smooth page transitions (PageRoute, CupertinoPageRoute)
- Implicit animations (AnimatedContainer, AnimatedOpacity)
- Explicit animations for complex interactions (AnimationController)
- Micro-interactions for button feedback
- Loading animations (shimmer, skeleton loaders)

### State Management
- Clear state management approach documented
- Proper data flow from widgets to screens
- Loading states handled gracefully
- Error states displayed appropriately
- Real-time updates (if applicable)

## Design Tools & Resources
- **Figma/Adobe XD:** For mockups and design specifications
- **Flutter DevTools:** For widget inspection and debugging
- **Google Material Design:** Design reference
- **Cupertino Design System:** For iOS-specific designs

## Output Requirements

When designing a UI screen or component:

1. **Design Specification**
   - Clear visual mockup or description
   - Component breakdown
   - Layout specifications

2. **Code Implementation**
   - Well-structured, readable Flutter code
   - Proper widget composition
   - Comments for complex sections
   - No hardcoded values (use theme/constants)

3. **Documentation**
   - Component usage guidelines
   - Responsive breakpoints
   - Interactive states documented
   - Accessibility notes

## Quality Assurance

Before finalizing any UI design:
- [ ] Design aligns with app branding
- [ ] Responsive on multiple device sizes
- [ ] Accessibility standards met
- [ ] Performance optimized (no jank)
- [ ] Consistent with existing app design language
- [ ] Production-ready code (no TODOs or placeholder code)
- [ ] Tested on both Android and iOS (if applicable)

## Anti-Patterns to Avoid

❌ Generic, template-like designs  
❌ Over-complicated layouts  
❌ Inconsistent typography or spacing  
❌ Poor color contrast or readability  
❌ Non-responsive designs  
❌ Unpolished or unrefined aesthetics  
❌ Unclear information hierarchy  
❌ Slow or janky animations  
❌ Inaccessible designs (color-blind unfriendly, small fonts)  
❌ "AI slop" placeholder designs  

## Success Criteria

A successful UI design/implementation should:
✅ Look professional and market-ready  
✅ Feel intuitive to pet owner users  
✅ Encourage app engagement  
✅ Follow Flutter best practices  
✅ Be responsive and performant  
✅ Maintain visual consistency  
✅ Be fully accessible  
✅ Require minimal future revisions  

---

**Version:** 1.0  
**Last Updated:** March 2026  
**Application:** Pet Owner Mobile App (Flutter)