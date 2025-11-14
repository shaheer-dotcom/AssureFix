const express = require('express');
const Service = require('../models/Service');
const auth = require('../middleware/auth');

const router = express.Router();

// Create a new service
router.post('/', auth, async (req, res) => {
  try {
    const {
      name,
      serviceName,
      description,
      category,
      area,
      areaCovered,
      price,
      pricePerHour,
      priceType
    } = req.body;

    // Validation
    if (!name || !description || !category || !area || !price) {
      return res.status(400).json({
        message: 'Name, description, category, area, and price are required'
      });
    }

    if (price < 100) {
      return res.status(400).json({
        message: 'Minimum price is ₹100'
      });
    }

    // Create new service
    const service = new Service({
      providerId: req.user._id,
      name: name.trim(),
      serviceName: serviceName || name.trim(),
      description: description.trim(),
      category,
      area: area.trim(),
      areaCovered: areaCovered || area.trim(),
      price,
      pricePerHour: pricePerHour || price,
      priceType: priceType || 'fixed',
      isActive: true
    });

    await service.save();
    await service.populate('providerId', 'profile.name profile.phoneNumber customerRating serviceProviderRating');

    console.log('Service created successfully:', service._id);

    res.status(201).json(service.toJSON());
  } catch (error) {
    console.error('Service creation error:', error);
    res.status(500).json({ message: 'Server error during service creation' });
  }
});

// Get all services (with search and filters)
router.get('/', async (req, res) => {
  try {
    let { search, category, location, page = 1, limit = 20 } = req.query;
    
    // Validate and sanitize pagination parameters
    page = Math.max(1, parseInt(page) || 1);
    limit = Math.min(100, Math.max(1, parseInt(limit) || 20)); // Max 100 items per page

    // Build query
    const query = { isActive: true };

    if (search) {
      // Case-insensitive search across multiple fields
      const searchRegex = new RegExp(search.replace(/[.*+?^${}()|[\]\\]/g, '\\$&'), 'i');
      query.$or = [
        { name: { $regex: searchRegex } },
        { serviceName: { $regex: searchRegex } },
        { description: { $regex: searchRegex } },
        { category: { $regex: searchRegex } }
      ];
    }

    if (category && category !== 'all') {
      query.category = category;
    }

    if (location) {
      // Case-insensitive location search - matches partial area names
      const locationRegex = new RegExp(location.replace(/[.*+?^${}()|[\]\\]/g, '\\$&'), 'i');

      if (query.$or) {
        // If search query already created $or, combine with location using $and
        query.$and = [
          { $or: query.$or },
          {
            $or: [
              { area: { $regex: locationRegex } },
              { areaCovered: { $regex: locationRegex } }
            ]
          }
        ];
        delete query.$or;
      } else {
        // If no search query, just add location filter
        query.$or = [
          { area: { $regex: locationRegex } },
          { areaCovered: { $regex: locationRegex } }
        ];
      }
    }

    const services = await Service.find(query)
      .populate('providerId', 'profile.name profile.phoneNumber customerRating serviceProviderRating')
      .sort({ createdAt: -1 })
      .limit(limit * 1)
      .skip((page - 1) * limit);

    const total = await Service.countDocuments(query);

    res.json({
      services,
      pagination: {
        current: page,
        pages: Math.ceil(total / limit),
        total
      }
    });
  } catch (error) {
    console.error('Get services error:', error);
    res.status(500).json({ message: 'Server error' });
  }
});

// Get services for a specific provider
router.get('/my-services', auth, async (req, res) => {
  try {
    const services = await Service.find({ providerId: req.user._id })
      .populate('providerId', 'profile.name profile.phoneNumber customerRating serviceProviderRating')
      .sort({ createdAt: -1 });

    res.json(services);
  } catch (error) {
    console.error('Get my services error:', error);
    res.status(500).json({ message: 'Server error' });
  }
});

// Get a specific service
router.get('/:id', async (req, res) => {
  try {
    const service = await Service.findById(req.params.id)
      .populate('providerId', 'profile.name profile.phoneNumber customerRating serviceProviderRating');

    if (!service) {
      return res.status(404).json({ message: 'Service not found' });
    }

    res.json(service);
  } catch (error) {
    console.error('Get service error:', error);
    res.status(500).json({ message: 'Server error' });
  }
});

// Update a service
router.put('/:id', auth, async (req, res) => {
  try {
    const service = await Service.findById(req.params.id);

    if (!service) {
      return res.status(404).json({ message: 'Service not found' });
    }

    // Check if user owns this service
    if (service.providerId.toString() !== req.user._id.toString()) {
      return res.status(403).json({ message: 'Not authorized to update this service' });
    }

    // Update service
    Object.assign(service, req.body);
    await service.save();
    await service.populate('providerId', 'profile.name profile.phoneNumber customerRating serviceProviderRating');

    console.log('Service updated successfully:', service._id);

    res.json({
      message: 'Service updated successfully',
      ...service.toJSON()
    });
  } catch (error) {
    console.error('Service update error:', error);
    res.status(500).json({ message: 'Server error during service update' });
  }
});

// Delete a service
router.delete('/:id', auth, async (req, res) => {
  try {
    const service = await Service.findById(req.params.id);

    if (!service) {
      return res.status(404).json({ message: 'Service not found' });
    }

    // Check if user owns this service
    if (service.providerId.toString() !== req.user._id.toString()) {
      return res.status(403).json({ message: 'Not authorized to delete this service' });
    }

    await Service.findByIdAndDelete(req.params.id);

    console.log('Service deleted successfully:', req.params.id);

    res.json({ message: 'Service deleted successfully' });
  } catch (error) {
    console.error('Service deletion error:', error);
    res.status(500).json({ message: 'Server error during service deletion' });
  }
});

// Toggle service active status
router.patch('/:id/toggle-status', auth, async (req, res) => {
  try {
    const service = await Service.findById(req.params.id);

    if (!service) {
      return res.status(404).json({ message: 'Service not found' });
    }

    // Check if user owns this service
    if (service.providerId.toString() !== req.user._id.toString()) {
      return res.status(403).json({ message: 'Not authorized to modify this service' });
    }

    service.isActive = !service.isActive;
    await service.save();
    await service.populate('providerId', 'profile.name profile.phoneNumber customerRating serviceProviderRating');

    console.log('Service status toggled:', service._id, 'Active:', service.isActive);

    res.json({
      message: 'Service status updated successfully',
      ...service.toJSON()
    });
  } catch (error) {
    console.error('Service status toggle error:', error);
    res.status(500).json({ message: 'Server error during status update' });
  }
});

module.exports = router;